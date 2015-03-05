#!/bin/env ruby
# encoding: utf-8
namespace :orzoro_tasks do
 
  desc "Esportazione bisettimanale degli utenti con TERM impostato a true"
  task :export, [:path] => :environment do |t, args|

    switch_tenant("orzoro")

    timestamp = "#{ DateTime.now.strftime("%Y%m%d") }235959"
    file_with_path = "#{args.path}orzoro_#{ timestamp }_IN.csv"

    # TODO: take users with terms true and completed true

    File.open(file, "w:UTF-8") do |csv|
      csv << compute_in(utente_gen).gsub(/\n/,"\r\n")    
    end
    
  end

  def compute_in(utente_gen)
    header ="\"PK_ID_Tprov\";\"PK_ID_Iprov\";\"PK_ID_Cprov\";\"LASTNAME\";\"FIRSTNAME\";\"RAGIONE_SOCIALE\";\"ADDRESS\";\"ADDRESS_NUM\";\"ZIPCODE\";\"CITY\";\"PROVINCE\";\"COUNTRY\";\"GENDER\";\"EMAIL\";\"FAMILY_MEMBERS_COUNT\";\"PRESENCE_OF_CHILDREN\";\"PRESENCE_OF_ANIMAL\";\"MARITAL_STATUS\";\"ACTUAL_JOB\";\"STUDY_LEVEL\";\"BIRTH_DATE\";\"AGE\";\"BIRTH_CITY\";\"BIRTH_PROVINCE\";\"PHONE_NUMBER_01\";\"PHONE_NUMBER_02\";\"MOBILE_NUMBER_01\";\"USERNAME\";\"DATE_REGISTRATION\";\"CHILD_WAITING\";\"CHILDREN_COUNT\";\"CHILDREN_NAME_01\";\"CHILDREN_GENDER_01\";\"CHILDREN_DOBDATE_01\";\"CHILDREN_NAME_02\";\"CHILDREN_GENDER_02\";\"CHILDREN_DOBDATE_02\";\"CHILDREN_NAME_03\";\"CHILDREN_GENDER_03\";\"CHILDREN_DOBDATE_03\";\"CHILDREN_NAME_04\";\"CHILDREN_GENDER_04\";\"CHILDREN_DOBDATE_04\";\"CHILDREN_NAME_05\";\"CHILDREN_GENDER_05\";\"CHILDREN_DOBDATE_05\";\"CHILDREN_NAME_06\";\"CHILDREN_GENDER_06\";\"CHILDREN_DOBDATE_06\";\"DOGS_COUNT\";\"CATS_COUNT\";\"RODENS_COUNT\";\"FISH_COUNT\";\"BIRDS_COUNT\";\"OTHER_SMALL_PETS_COUNT\";\"OTHER_SMALL_PETS_DESC\";\"DOG_NAME_01\";\"DOG_CLASS_01\";\"DOG_DOBDATE_01\";\"DOG_SIZE_01\";\"DOG_CIBO_PREF_01\";\"DOG_NAME_02\";\"DOG_CLASS_02\";\"DOG_DOBDATE_02\";\"DOG_SIZE_02\";\"DOG_CIBO_PREF_02\";\"DOG_NAME_03\";\"DOG_CLASS_03\";\"DOG_DOBDATE_03\";\"DOG_SIZE_03\";\"DOG_CIBO_PREF_03\";\"CAT_NAME_01\";\"CAT_CLASS_01\";\"CAT_DOBDATE_01\";\"CAT_CIBO_PREF_01\";\"CAT_GOURMET_PREF_01\";\"CAT_NAME_02\";\"CAT_CLASS_02\";\"CAT_DOBDATE_02\";\"CAT_CIBO_PREF_02\";\"CAT_GOURMET_PREF_02\";\"CAT_NAME_03\";\"CAT_CLASS_03\";\"CAT_DOBDATE_03\";\"CAT_CIBO_PREF_03\";\"CAT_GOURMET_PREF_03\";\"TIPO_LOCALE\";\"PROFILO_PROFESSIONALE\";\"DOVE_CONOSC_PRODOTTI\";\"PRODOTTO_INTERESSE\";\"OPTIN_CMZ_MIO_BC\";\"OPTIN_CMZ_MIO_BC_DATE\";\"HOW_REACH_MIO_BC\";\"WHY_OPTOUT_NEWS_CROSS\";\"WHY_OPTOUT_NEWS_BRAND\";\"VAR_DATA_01\";\"VAR_DATA_02\";\"VAR_DATA_03\";\"VAR_DATA_04\";\"VAR_DATA_05\";\"NUM_DATA_01\";\"NUM_DATA_02\";\"NUM_DATA_03\";\"NUM_DATA_04\";\"NUM_DATA_05\";\"FLAG_DATA_01\";\"FLAG_DATA_02\";\"FLAG_DATA_03\";\"FLAG_DATA_04\";\"FLAG_DATA_05\";\"NEWSLETTER_TYPE_01\";\"NEWSLETTER_TYPE_02\";\"NEWSLETTER_TYPE_03\";\"NEWSLETTER_TYPE_04\";\"NEWSLETTER_TYPE_05\";\"INFO_TYPE_01\";\"INFO_TYPE_02\";\"INFO_TYPE_03\";\"INFO_TYPE_04\";\"INFO_TYPE_05\";\"GOLD_QUESTION_01\";\"GOLD_QUESTION_02\";\"GOLD_QUESTION_03\";\"GOLD_QUESTION_04\";\"GOLD_QUESTION_05\";\"GOLD_QUESTION_06\";\"GOLD_QUESTION_07\";\"GOLD_QUESTION_08\";\"GOLD_QUESTION_09\";\"GOLD_QUESTION_10\";\"GOLD_QUESTION_11\";\"GOLD_QUESTION_12\";\"GOLD_QUESTION_13\";\"GOLD_QUESTION_14\";\"GOLD_QUESTION_15\";\"PROFILAZIONE_BRAND\";\"AGE_13\";\"PRIVACY_NES\";\"PRIVACY_NWI\";\"OPTIN_CMZ_BRAND\";\"OPTIN_CMZ_NES_CROSS\";\"OPTIN_CMZ_NWI_CROSS\";\"OPTIN_MOBILE\";\"OPTIN_MOBILE_FASCIA\";\"DATE_DATA_01\";\"DATE_DATA_02\";\"DATE_UPDATE_AGENCY\"\n"
    csv = header

    if utente_gen
      utente_gen.each do |utente|
        day = utente.day_birth_on.to_s unless utente.day_birth_on.blank?
        month = utente.month_birth_on.to_s unless utente.month_birth_on.blank?
        year = utente.year_birth_on.to_s unless utente.year_birth_on.blank?

        if (utente.day_birth_on.present? && utente.month_birth_on.present? && utente.year_birth_on.present?)

          day = "0" + day if day.length < 2
          month = "0" + month if month.length < 2

          user_maggiore_13 = "1"
          user_maggiore_13_bool = DateTime.parse('1999-10-15').to_time > DateTime.parse("#{year}-#{month}-#{day}").to_time
          unless user_maggiore_13_bool
            user_maggiore_13 = "0"
          end

        end

        csv << "\"WEB\";"
        csv << "\"orzoro\";"
        csv << "\"" + utente.id.to_s + "\";"
        csv << "\"" + utente.last_name + "\";"
        csv << "\"" + utente.first_name + "\";"

        csv << "\"\";" # Ragione sociale
        csv << "\"\";" # Indirizzo
        csv << "\"\";" # Numero Civico

        csv << "\"\";" # Zipcode

        csv << "\"\";" # City
        csv << "\"\";" # Province

        csv << "\"\";" # Country
        csv << "\"\";" # Gender

        csv << "\"" + utente.email + "\";"

        6.times do |i|
          csv << "\"\";"
        end

        if year && month && day
          csv << "\"" + year + "" + month + "" + day + "\";"
        else
          csv << "\"\";"
        end

        7.times do |i|
          csv << "\"\";"
        end

        csv << "\"" + utente.created_at.to_date.strftime("%Y%m%d") + "\";"

        107.times do |i|
          csv << "\"\";"
        end

        if utente.newsletter.blank?
          newsletter = "N"
        else
          newsletter = "G"
        end

        user_maggiore_13 = "1" unless user_maggiore_13
        csv << "\"" + user_maggiore_13 + "\";"

        csv << "\"G\";"
        csv << "\"G\";"

        csv << "\"#{utente.newsletter_for_in_out}\";"

        csv << "\"#{utente.terms_for_in_out == "D" ? "D" : utente.terms_for_in_out }\";"
        csv << "\"#{utente.terms_for_in_out == "D" ? "D" : utente.terms_for_in_out }\";"

        csv << "\"N\";"
        csv << "\"N\";"
        
        2.times do |i|
          csv << "\"\";"
        end

        csv << "\"" + utente.updated_at_for_in_out.strftime("%Y%m%d") + "\"\n"
      end
    end

    csv

  end 

  def compute_out
    Dir['/srv/www/www.orzoro.it/csv/OUT/*.csv'].sort.each do |file|
      File.open(file, "r").each_with_index do |row, index|

        if index > 0

          id_tprov, 
          id_iprov, 
          id_cprov, 
          privacy_nes, 
          privacy_nwi, 
          optin_cmz_brand, 
          optin_cmz_nes_cross, 
          optin_cmz_nwi_cross, 
          optin_mobile = row.gsub("\"", "").split(";")

          user_id, cup = compute_fandom_id(id_cprov)

          if cup
            user_redeem_cup = ::Experience::UserRedeemCup.find_by_id(user_id)
            user = Core::User.where("LOWER(email) = ? ", user_redeem_cup.email.downcase).first
          else
            user = Core::User.find_by_id(user_id)
          end

          if user.present?
            puts "#{index - 1} #{user.email}"
            update_user = false
            
            if user.terms_for_in_out == "G" && (optin_cmz_nes_cross == "D" || optin_cmz_nwi_cross == "D")
              user.terms_for_in_out = "D"
              update_user = true
            elsif user.terms_for_in_out == "D" && (optin_cmz_nes_cross == "G" && optin_cmz_nwi_cross == "G")
              user.terms = true
              user.terms_for_in_out = "G"
              update_user = true
            end

            if user.newsletter_for_in_out == "G" && optin_cmz_brand == "D"
              user.newsletter_for_in_out = "D"
              update_user = true
            elsif user.newsletter_for_in_out == "D" && optin_cmz_brand == "G"
              user.newsletter = true
              user.newsletter_for_in_out = "G"
              update_user = true
            end

            if update_user
              user.updated_at_for_in_out = Time.now
              user.save
            end
          end

        end

      end
      FileUtils.mv(file, "/srv/www/www.orzoro.it/CSV-OUT-CLOSE")
    end
  end

end

