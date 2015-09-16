module CacheHelper  
  def cached_nil?(cached_value)
    cached_value.class == CachedNil
  end

  # Caches a rails template, that should be passed as block.
  #
  # key       - A simple string, or a model (or an array of models) from which the template depends
  # condition - The cache is performed only if condition is true
  def template_cache_short(key, condition=true, &block)
    template_cache_aux(key, condition, 1.minute, &block)
  end
  def template_cache_medium(key, condition=true, &block)
    template_cache_aux(key, condition, 5.minute, &block)
  end
  def template_cache_long(key, condition=true, &block)
    template_cache_aux(key, condition, 1.hour, &block)
  end
  def template_cache_huge(key, condition=true, &block)
    template_cache_aux(key, condition, 1.day, &block)
  end

  # cache a block for a set amount of time
  def cache_short(key = nil, &block)
    cache_aux(key, 1.minute, &block)
  end
  def cache_medium(key = nil, &block)
    cache_aux(key, 5.minute, &block)
  end
  def cache_long(key = nil, &block)
    cache_aux(key, 1.hour, &block)
  end
  def cache_huge(key = nil, &block)
    cache_aux(key, 1.day, &block)
  end
  def cache_forever(key = nil, &block)
    cache_aux(key, nil, &block)
  end
  
  def cache_write_short(key, value)
    cache_write(key, value, 1.minute)  
  end

  def cache_write_long(key, value)
    cache_write(key, value, 1.hour)  
  end

  def cache_write(key, value, expires_in)
    actual_key = get_cache_key(key)
    log_info("rewriting cache key", { key: actual_key })
    Rails.cache.write(actual_key, value, :expires_in => expires_in, :race_condition_ttl => 30)
  end

  def cache_read(key)
    actual_key = get_cache_key(key)
    Rails.cache.read(actual_key)
  end

  def get_cache_key(key = nil)
    if key.nil?
      # WARNING: this statement assumes that get_cache_key is used at a certain call stack depth. 
      # Refactoring the code without changing this line might corrupt the cache!
      my_call_stack = caller[2]
      parts = my_call_stack.split(':')
      part = parts[0].split('/')[-1]
      key = "#{part}:#{parts[1]}"
    end
    result = "f:#{$site.id}:#{key}"
    result
  end
  
  def may_get_template_cache_key(key)
    if key.is_a? String
      [$site.id, key]
    elsif key.is_a? Array
      [$site.id] + key
    else
      log_error("bad cache key", { key: key.to_s, key_class: key.class })
      nil
    end
  end

  def cache_aux(key = nil, expires_in, &block)

    cache_key = get_cache_key(key)

    block_run = false    
    wrapped_block = lambda do
      start_time = Time.now.utc 
      block_run = true 
      block_result = yield block
      time = (Time.now.utc - start_time)
      log_debug("cache miss computation", { 'key' => cache_key, "time" => time })
      block_result 
    end
    
    if expires_in.nil?
      result = Rails.cache.fetch(cache_key, :expires_in => 0, :race_condition_ttl => 30, &wrapped_block)
    else
      result = Rails.cache.fetch(cache_key, :expires_in => expires_in, :race_condition_ttl => 30, &wrapped_block)
    end
    
    if block_run
      $cache_misses += 1
    else
      $cache_hits += 1
    end
    result
  end

  def template_cache_aux(key, condition, expires_in, &block)
    start_time = Time.now.utc 
  
    cache_key = may_get_template_cache_key(key)
    if cache_key.nil? or !condition
      result = yield block
    else
  
      block_run = false    
      wrapped_block = lambda  do
        block_run = true 
        block_result = yield block
        block_result 
      end
      
      result = cache(cache_key, :expires_in => expires_in, :race_condition_ttl => 30, &wrapped_block)
      
      time = (Time.now.utc - start_time) 
  
      if block_run
        log_debug("cache miss", { 'key' => cache_key, "time" => time })
      else
        log_info("cache hit", { 'key' => cache_key,  "time" => time })
      end
      result
    end
  end

  def expire_cache_key(key)
    actual_key = get_cache_key(key)
    log_debug("expiring cache key", { key: actual_key })
    Rails.cache.delete(actual_key)
  end
  
  # Enable browser caching. is_public set to false instruct any intermediary cache (such as web proxies) 
  # to not share the content for multiple users  
  def browser_caching(seconds, is_public=true)
    if request.method == 'GET' || request.method == 'HEAD' 
      # this would be useful for akamai
      #headers['Edge-control'] = "!no-store, max-age=#{seconds/60}"
      
      expires_in seconds, :public => is_public, 'max-stale' => 0, 'must-revalidate' => true
    end
  end

  # Handle headers in the response to allow frontend caching. Warning: it removes the session cookie, so this 
  # method should be called only from controller actions that does not require it  
  def edge_caching(seconds)
    if current_user.nil?
      env['rack.session.options'][:skip] = true
      
      # this tells nginx to ignore the Cache-Control header, used by browsers, and cache the resource for X seconds  
      response.headers["X-Accel-Expires"] = seconds
    end
  end


end
