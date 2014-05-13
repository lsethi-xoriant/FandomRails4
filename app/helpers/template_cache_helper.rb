module TemplateCacheHelper
  def template_cache_short(key, &block)
    cache(key, :expires_in => 1.minute, :race_condition_ttl => 30, &block)
  end
  def template_cache_medium(key, &block)
    cache(key, :expires_in => 5.minute, :race_condition_ttl => 1.minute, &block)
  end
  def template_cache_long(key, &block)
    cache(key, :expires_in => 1.hour, :race_condition_ttl => 5.minute, &block)
  end
  def template_cache_huge(key, &block)
    cache(key, :expires_in => 1.day, :race_condition_ttl => 1.hour, &block)
  end
end
