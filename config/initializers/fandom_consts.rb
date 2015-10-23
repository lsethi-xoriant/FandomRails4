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

  EMOTICONS = [0x1f601, 0x1f602, 0x1f603, 0x1f604, 0x1f605, 0x1f606, 0x1f609, 0x1f60a, 0x1f60b, 0x1f60c, 0x1f60d, 0x1f60f, 0x1f612, 0x1f613, 0x1f614, 0x1f616, 0x1f618, 0x1f61a, 0x1f61c, 0x1f61d, 0x1f61e, 0x1f620, 0x1f621, 0x1f622, 0x1f623, 0x1f624, 0x1f625, 0x1f628, 0x1f629, 0x1f62a, 0x1f62b, 0x1f62d, 0x1f630, 0x1f631, 0x1f632, 0x1f633, 0x1f635, 0x1f637, 0x1f638, 0x1f639, 0x1f63a, 0x1f63b, 0x1f63c, 0x1f63d, 0x1f63e, 0x1f63f, 0x1f640, 0x1f645, 0x1f646, 0x1f647, 0x1f648, 0x1f649, 0x1f64a, 0x1f64b, 0x1f64c, 0x1f64d, 0x1f64e, 0x1f64f]

  # Trivia and Versus are just subtypes of Quiz; Registration is a subtype of Basic as well
  INTERACTION_TYPES = Set.new(['Link', 'Quiz', 'Trivia', 'Versus', 'Check', 'Comment', 'Like', 'Play', 'Share', 'Download', 'Upload', 'Vote', 'Test', 'Basic', 'Registration'])
  
  COUNTER_NAMES = INTERACTION_TYPES.map { |x| "ALL_#{x.upcase}" } + INTERACTION_TYPES.map { |x| "UNIQUE_#{x.upcase}" } + ['UNIQUE_TRIVIA_CORRECT_ANSWER', 'ALL_TRIVIA_CORRECT_ANSWER']
  
  DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  
  REWARDING_RULE_SETTINGS_KEY = 'rewarding.rules'
  BROWSE_SETTINGS_KEY = 'browse.setting'
  BROWSE_CAROUSEL_SETTING_KEY = 'browse.carousel.setting'
  RANKING_SETTINGS_KEY = 'ranking.setting'
  NOTIFICATIONS_SETTINGS_KEY = 'notifications.setting'
  CHANNELS_SETTINGS_KEY = 'channels.setting'
  ACTIVE_PROFANITIES_SETTINGS_KEY = 'profanity.filter.automatic'
  PROFANITIES_SETTINGS_KEY = 'profanity.words'
  INSTAGRAM_CALLBACK_URL = 'instagram.callback.url'
  INSTAGRAM_SUBSCRIPTIONS_SETTINGS_KEY = 'instagram.subscriptions'
  FACEBOOK_SUBSCRIPTIONS_SETTINGS_KEY = 'facebook.subscriptions'
  TWITTER_SUBSCRIPTIONS_SETTINGS_KEY = 'twitter.subscriptions'
  NOTIFICATIONS_LIMIT_DEFAULT = 50
  NOTIFICATIONS_LIMIT_KEY = 'notifications.limit'
  PROPERTIES_LIST_KEY = 'properties.list'

  INTESA_FILTER_TAG_KEY = 'intesa.filter'

  UPLOAD_APPROVED_LABEL = "Upload approvato"
  COMMENT_APPROVED_LABEL = "Commento approvato"
  USER_CTA_INTERACTIONS_LABEL = "Interazioni su cta utente"
  
  MEDIA_TYPES = ["VOID", "IMAGE", "YOUTUBE", "KALTURA", "FLOWPLAYER", "IFRAME", "HTML5VIDEO"]
  ALLOWED_UPLOAD_MEDIA_TYPES = ["FLOWPLAYER"]
  PERIOD_TYPES = ["GIORNALIERA", "SETTIMANALE", "MENSILE", "GLOBALE"]
  RANKING_TYPES = {"full" => "Top10", "my_position" => "La mia posizione", "trirank" => "Triclassifica", "full_compressed" => "Triclassifica (smart)"}
  RANKING_USER_FILTER = {"all" => "Tutti", "fb_friends" => "Amici di facebook"}
  
  BYTES_IN_MEGABYTE = 1048576
  MAX_UPLOAD_SIZE = 3 # Megabyte (Mb)
  
  PERIOD_KIND_TOTAL = "total"
  PERIOD_KIND_DAILY = "daily"
  PERIOD_KIND_WEEKLY = "weekly"
  PERIOD_KIND_MONTHLY = "monthly"
  
  RANKING_USER_PER_PAGE = 10
  
  MAIN_REWARD_NAME = "point"
  TO_BE_NOTIFIED_REWARD_NAME = "to-be-notified"  
  
  MAILER_DEFAULT_FROM = "noreply@shado.tv"
  
  BALLANDO_DAILY_CHECK_CAP = 10
  
  REWARD_SORT_BY_VALIDITY_END = "valid_to"
  REWARD_SORT_BY_NAME = "name"
  REWARD_SORT_BY_TITLE = "title"
  CTA_REWARD_TAG = "reward-cta"
  
  CTA_DEFAULT_BUTTON_LABEL = "Guarda"
  
  USER_TIME_ZONE = "Rome"
  USER_TIME_ZONE_ABBREVIATION = "CET"

  WORLD_STATES = ["Italia", "Abcasia", "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua e Barbuda", "Arabia Saudita", 
    "Argentina", "Armenia", "Australia", "Austria", "Azawad", "Azerbaigian", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belgio", 
    "Belize", "Benin", "Bhutan", "Bielorussia", "Bolivia", "Bosnia ed Erzegovina", "Botswana", "Brasile", "Brunei", "Bulgaria", 
    "Burkina Faso", "Burundi", "Cambogia", "Camerun", "Canada", "Capo Verde", "Ciad", "Cile", "Cina", "Cipro", "Cipro del Nord", 
    "Citta' del Vaticano", "Colombia", "Comore", "Corea del Nord", "Corea del Sud", "Costa d'Avorio", "Costa Rica", "Croazia", 
    "Cuba", "Danimarca", "Dominica", "Ecuador", "Egitto", "El Salvador", "Emirati Arabi Uniti", "Eritrea", "Estonia", "Etiopia", "Figi", 
    "Filippine", "Finlandia", "Francia", "Gabon", "Gambia", "Georgia", "Germania", "Ghana", "Giamaica", "Giappone", "Gibuti", "Giordania", 
    "Grecia", "Grenada", "Guatemala", "Guinea", "Guinea Equatoriale", "Guinea-Bissau", "Guyana", "Haiti", "Honduras", "India", "Indonesia", 
    "Iran", "Iraq", "Irlanda", "Islanda", "Isole Marshall", "Isole Salomone", "Israele", "Italia", "Kazakistan", "Kenya", "Kirghizistan", "Kiribati", 
    "Kosovo", "Kuwait", "Laos", "Lesotho", "Lettonia", "Libano", "Liberia", "Libia", "Liechtenstein", "Lituania", "Lussemburgo", 
    "Madagascar", "Malawi", "Maldive", "Malesia", "Mali", "Malta", "Marocco", "Mauritania", "Mauritius", "Messico", "Micronesia", 
    "Moldavia", "Mongolia", "Montenegro", "Mozambico", "Myanmar", "Nagorno-Karabakh", "Namibia", "Nauru Yaren", "Nepal", "Nicaragua", 
    "Niger", "Nigeria", "Norvegia", "Nuova Zelanda", "Oman", "Ossezia del Sud", "Paesi Bassi", "Pakistan", "Palau", "Panama", 
    "Papua Nuova Guinea", "Paraguay", "Peru", "Polonia", "Portogallo", "Principato di Monaco", "Qatar", "Regno Unito", "Repubblica Ceca", 
    "Repubblica Centrafricana", "Repubblica del Congo", "Repubblica Democratica del Congo", "Repubblica di Macedonia", 
    "Repubblica Dominicana", "Romania", "Ruanda", "Russia", "Saint Kittse Nevis", "Saint Vincent e Grenadine", "Samoa", "San Marino", 
    "Santa Lucia", "Sao Tomee Principe", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Siria", "Slovacchia", "Slovenia", 
    "Somalia", "Somaliland", "Spagna", "SriLanka", "Stati Uniti d'America", "Sudafrica", "Sudan", "Sudan del Sud", "Suriname", "Svezia", 
    "Svizzera", "Swaziland", "Tagikistan", "Taiwan", "Tanzania", "Thailandia", "Timor Est", "Togo", "Tonga", "Transnistria", 
    "Trinidad e Tobago", "Tunisia", "Turchia", "Turkmenistan", "Tuvalu", "Ucraina", "Uganda", "Ungheria", "Uruguay", "Uzbekistan", "Vanuatu", 
    "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"]

  ITALIAN_PROVINCES = ["AG", "AL", "AN", "AO", "AP", "AQ", "AR", "AT", "AV", "BA", "BG", "BI", "BL", "BN", "BO", "BR", "BS", "BT", "BZ", 
    "CA", "CB", "CE", "CH", "CI", "CL", "CN", "CO", "CR", "CS", "CT", "CZ", "EN", "FC", "FE", "FG", "FI", "FO", "FR", "GE", "GO", "GR", 
    "IM", "IS", "KR", "LC", "LE", "LI", "LO", "LT", "LU", "MB", "MC", "ME", "MI", "MN", "MO", "MS", "MT", "NA", "NO", "NU", "OG", "OR", 
    "OT", "PA", "PC", "PD", "PE", "PG", "PI", "PN", "PO", "PR", "PS", "PT", "PV", "PZ", "RA", "RC", "RE", "RG", "RI", "RM", "RN", "RO", 
    "SA", "SI", "SO", "SP", "SR", "SS", "SV", "TA", "TE", "TN", "TO", "TP", "TR", "TS", "TV", "UD", "VA", "VB", "VC", "VE", "VI", "VR", 
    "VS", "VT", "VV"]

  MONTH_NAMES = ["", "gennaio", "febbraio", "marzo", "aprile", "maggio", "giugno", "luglio", "agosto", "settembre", "ottobre", "novembre", "dicembre"]
  
  SUPERFAN_CONTEST_REWARD = "contest-point"
  SUPERFAN_CONTEST_POINTS_TO_WIN = 200
  SUPERFAN_CONTEST_ACTIVE = false
  
  COIN_GIFT_500 = {"name" => "gift_card_500", "qta" => 1}
  COIN_GIFT_100 = {"name" => "gift_card_100", "qta" => 10}
  COIN_GIFT_50 = {"name" => "gift_card_50", "qta" => 24}
  COIN_PRIZES_LIST = [COIN_GIFT_500, COIN_GIFT_100, COIN_GIFT_50]
  COIN_CONTEST_START_DATE = "04/12/2014 11:00:00 Rome"
  COIN_CONTEST_END_DATE = "07/01/2015 17:00:00 Rome"

  REGEX_SPECIAL_CHARS = ["\\", "^", "$", ".", "|", "?", "*", "+", "(", ")", "[", "{"]

  MD5_FANDOM_PREFIX = "f4nd0m"
  
  class CachedNil
  end

  CACHED_NIL = CachedNil.new

  LOG_MESSAGE_CONTENT_VIEWED = 'content viewed'

  WHEN_SHOW_USER_INTERACTION = ["SEMPRE_VISIBILE", "OVERVIDEO_DURING", "OVERVIDEO_DURING_WITH_CHAPTERING", "OVERVIDEO_START", "OVERVIDEO_END", "MAI_VISIBILE"]
  
  INDEX_CATEGORY_CTA_STATUS_ACTIVE = true
  FULL_SEARCH_CTA_STATUS_ACTIVE = true
  
  AUTOCOMPLETE_DELAY = 300
  
  DEFAULT_VIEW_ALL_ELEMENTS = 12
  DEFAULT_BROWSE_ELEMENT_CAROUSEL = 8

  X_FRAME_OPTIONS_HEADER_SAME_ORIGIN = 'SAMEORIGIN'
  X_FRAME_OPTIONS_HEADER_DENY = 'DENY'
  X_FRAME_OPTIONS_HEADER_ALLOW_FROM = 'ALLOW-FROM'

  CONTEST_IDENTITY_COLLECTION_START_DATE = "2015/09/15"
  CONTEST_BRAUN_IW_START_DATE = "2015/09/03"

end