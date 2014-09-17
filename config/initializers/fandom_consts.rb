unless defined? FILTER_OPERATOR_CONTAINS
  # Constants use by generic table widget
  FILTER_OPERATOR_CONTAINS = "contains"
  FILTER_OPERATOR_BETWEEN = "between"
  FILTER_OPERATOR_LESS = "less than"
  FILTER_OPERATOR_LESS_EQUAL = "less or equal than"
  FILTER_OPERATOR_MORE = "more than"
  FILTER_OPERATOR_MORE_EQUAL = "more than"
  FILTER_OPERATOR_EQUAL = "equal to"
  
  REWARD_BIG_IMAGE_SIZE = "400x400"
  REWARD_MEDIUM_IMAGE_SIZE = "200x200"
  REWARD_SMALL_IMAGE_SIZE = "100x100"
  
  MAXIBON_DAILY_ACCESS = 1
  MAXIBON_PARTY_GUETTA = 2
  MAXIBON_PARTY_NIGHT = 3
  
  # Trivia and Versus are just subtypes of Quiz
  INTERACTION_TYPES = Set.new(['Quiz', 'Trivia', 'Versus', 'Check', 'Comment', 'Like', 'Play', 'Share', 'Download', 'Upload', 'Vote'])
  
  COUNTER_NAMES = INTERACTION_TYPES.map { |x| "ALL_#{x.upcase}" } + INTERACTION_TYPES.map { |x| "UNIQUE_#{x.upcase}" } + ['UNIQUE_TRIVIA_CORRECT_ANSWER', 'ALL_TRIVIA_CORRECT_ANSWER']
  
  DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  
  REWARDING_RULE_SETTINGS_KEY = 'rewarding.rules'
  BROWSE_SETTINGS_KEY = 'browse.setting'
  
  MEDIA_TYPES = ["VOID", "IMAGE", "YOUTUBE", "IFRAME"]
  PERIOD_TYPES = ["GIORNALIERA", "SETTIMANALE", "MENSILE", "GLOBALE"]
  RANKING_TYPES = {"full" => "Top10", "my_position" => "La mia posizione", "trirank" => "Triclassifica", "full_compressed" => "Triclassifica (smart)"}
  RANKING_USER_FILTER = {"all" => "Tutti", "fb_friends" => "Amici di facebook"}
  
  LOGGER_PROCESS_FILE_SIZE = 1024*1024
  
  BYTES_IN_MEGABYTE = 1048576
  MAX_UPLOAD_SIZE = 3 #Megabyte (Mb)
  
  PERIOD_KIND_TOTAL = "TOTAL"
  PERIOD_KIND_DAILY = "DAILY"
  PERIOD_KIND_WEEKLY = "WEEKLY"
  PERIOD_KIND_MONTHLY = "MONTHLY"
  
  RANKING_USER_PER_PAGE = 10
  
  MAIN_REWARD_NAME = "point"  
  
  MAILER_DEFAULT_FROM = "noreply@shado.tv"
  
  BALLANDO_DAILY_CHECK_CAP = 10
  
end