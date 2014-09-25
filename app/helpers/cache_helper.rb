require 'fandom_utils'

module CacheHelper
  include FandomUtils

  # TODO: currently untested
  def template_cache_short(key = nil, &block)
    template_cache_aux(key, 1.minute, &block)
  end
  def template_cache_medium(key = nil, &block)
    template_cache_aux(key, 5.minute, &block)
  end
  def template_cache_long(key = nil, &block)
    template_cache_aux(key, 1.hour, &block)
  end
  def template_cache_huge(key = nil, &block)
    template_cache_aux(key, 1.day, &block)
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

  def get_cache_key(key = nil)
    site = get_site_from_request!
    if key.nil?
      # WARNING: this statement assumes that get_cache_key is used at a certain call stack depth. 
      # Refactoring the code without changing this line might corrupt the cache!
      my_call_stack = caller[2]
      parts = my_call_stack.split(':')
      part = parts[0].split('/')[-1]
      key = "#{part}:#{parts[1]}"
    end
    result = "#{site.id}:#{key}"
    result
  end

  def cache_aux(key = nil, expires_in, &block)
    cache_key = get_cache_key(key)
    
    block_time = nil
    wrapped_block = lambda  do
      start_time = Time.now.utc 
      block_result = yield block
      block_time = (Time.now.utc - start_time) 
      block_result 
    end
    
    result = Rails.cache.fetch(cache_key, :expires_in => expires_in, :race_condition_ttl => 30, &wrapped_block)
    
    if block_time.nil?
      log_info("cache hit", { 'key' => cache_key })
    else
      log_info("cache miss", { 'key' => cache_key, "time" => block_time })
    end
    result
  end

  def template_cache_aux(key = nil, expires_in, &block)
    cache_key = get_cache_key(key)
    
    block_time = nil
    wrapped_block = lambda  do
      start_time = Time.now.utc 
      block_result = yield block
      block_time = (Time.now.utc - start_time) 
      block_result 
    end
    
    result = cache(cache_key, :expires_in => expires_in, :race_condition_ttl => 30, &wrapped_block)
    
    if block_time.nil?
      log_info("cache hit", { 'key' => cache_key })
    else
      log_info("cache miss", { 'key' => cache_key, "time" => block_time })
    end
    result
  end

  def expire_cache_key(key)
    actual_key = get_cache_key(key)
    log_info("expiring cache key", { key: actual_key })
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
