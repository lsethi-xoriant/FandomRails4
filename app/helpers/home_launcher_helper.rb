module HomeLauncherHelper
  def active_home_launchers()
    cache_short('home_launcher') do
      HomeLauncher.active.to_a
    end
  end
end
