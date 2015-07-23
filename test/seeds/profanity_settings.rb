profanity_filter_automatic_setting = Setting.where(:key => "profanity.filter.automatic").first_or_create
profanity_filter_automatic_setting.value = "t"
profanity_filter_automatic_setting.save

profanities_for_testing = "profanity,profanities,badword,badwords"
word_list_setting = Setting.where(:key => 'profanity.words').first_or_create
word_list_setting.value = (word_list_setting.value || "") << profanities_for_testing
word_list_setting.save