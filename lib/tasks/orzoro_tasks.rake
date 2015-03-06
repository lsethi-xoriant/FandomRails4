#!/bin/env ruby
# encoding: utf-8

namespace :orzoro_tasks do
 
  desc "Esportazione bisettimanale degli utenti con TERM impostato a true"
  task :export, [:in_path] => :environment do |t, args|

    switch_tenant("orzoro")

    timestamp = "#{DateTime.now.strftime("%Y%m%d")}235959"
    file_with_path = "#{args.in_path}orzoro_#{ timestamp }_IN.csv"

    # Send users with terms 1 (accepted) or -1 (accepted and unaccepted)
    users = User.where("aux->>'terms' <> '0' AND aux->>'sync_timestamp' = ''")

    File.open(file_with_path, "w:UTF-8") do |csv|
      csv << compute_in(users)  
    end
    
  end

  desc "Importazione utenti modificati da Orzoro"
  task :import, [:out_path, :out_mv_path] => :environment do |t, args|

    switch_tenant("orzoro")
    compute_out(args.out_path, args.out_mv_path)
    
  end

  def build_semicolon(n)
    csv = ""
    n.times do |x| 
      csv << "\"\";" 
    end
    csv
  end

  def compute_terms_or_newsletter_value(value)
    orzoro_value = ""
    case value
    when "1"
      orzoro_value = "G"
    when "0"
      orzoro_value = "N"
    else
      orzoro_value = "D"
    end
    orzoro_value
  end

  def compute_in(users)
    csv = "\"PK_ID_Tprov\";\"PK_ID_Iprov\";\"PK_ID_Cprov\";\"LASTNAME\";\"FIRSTNAME\";\"RAGIONE_SOCIALE\";\"ADDRESS\";\"ADDRESS_NUM\";\"ZIPCODE\";\"CITY\";\"PROVINCE\";\"COUNTRY\";\"GENDER\";\"EMAIL\";\"FAMILY_MEMBERS_COUNT\";\"PRESENCE_OF_CHILDREN\";\"PRESENCE_OF_ANIMAL\";\"MARITAL_STATUS\";\"ACTUAL_JOB\";\"STUDY_LEVEL\";\"BIRTH_DATE\";\"AGE\";\"BIRTH_CITY\";\"BIRTH_PROVINCE\";\"PHONE_NUMBER_01\";\"PHONE_NUMBER_02\";\"MOBILE_NUMBER_01\";\"USERNAME\";\"DATE_REGISTRATION\";\"CHILD_WAITING\";\"CHILDREN_COUNT\";\"CHILDREN_NAME_01\";\"CHILDREN_GENDER_01\";\"CHILDREN_DOBDATE_01\";\"CHILDREN_NAME_02\";\"CHILDREN_GENDER_02\";\"CHILDREN_DOBDATE_02\";\"CHILDREN_NAME_03\";\"CHILDREN_GENDER_03\";\"CHILDREN_DOBDATE_03\";\"CHILDREN_NAME_04\";\"CHILDREN_GENDER_04\";\"CHILDREN_DOBDATE_04\";\"CHILDREN_NAME_05\";\"CHILDREN_GENDER_05\";\"CHILDREN_DOBDATE_05\";\"CHILDREN_NAME_06\";\"CHILDREN_GENDER_06\";\"CHILDREN_DOBDATE_06\";\"DOGS_COUNT\";\"CATS_COUNT\";\"RODENS_COUNT\";\"FISH_COUNT\";\"BIRDS_COUNT\";\"OTHER_SMALL_PETS_COUNT\";\"OTHER_SMALL_PETS_DESC\";\"DOG_NAME_01\";\"DOG_CLASS_01\";\"DOG_DOBDATE_01\";\"DOG_SIZE_01\";\"DOG_CIBO_PREF_01\";\"DOG_NAME_02\";\"DOG_CLASS_02\";\"DOG_DOBDATE_02\";\"DOG_SIZE_02\";\"DOG_CIBO_PREF_02\";\"DOG_NAME_03\";\"DOG_CLASS_03\";\"DOG_DOBDATE_03\";\"DOG_SIZE_03\";\"DOG_CIBO_PREF_03\";\"CAT_NAME_01\";\"CAT_CLASS_01\";\"CAT_DOBDATE_01\";\"CAT_CIBO_PREF_01\";\"CAT_GOURMET_PREF_01\";\"CAT_NAME_02\";\"CAT_CLASS_02\";\"CAT_DOBDATE_02\";\"CAT_CIBO_PREF_02\";\"CAT_GOURMET_PREF_02\";\"CAT_NAME_03\";\"CAT_CLASS_03\";\"CAT_DOBDATE_03\";\"CAT_CIBO_PREF_03\";\"CAT_GOURMET_PREF_03\";\"TIPO_LOCALE\";\"PROFILO_PROFESSIONALE\";\"DOVE_CONOSC_PRODOTTI\";\"PRODOTTO_INTERESSE\";\"OPTIN_CMZ_MIO_BC\";\"OPTIN_CMZ_MIO_BC_DATE\";\"HOW_REACH_MIO_BC\";\"WHY_OPTOUT_NEWS_CROSS\";\"WHY_OPTOUT_NEWS_BRAND\";\"VAR_DATA_01\";\"VAR_DATA_02\";\"VAR_DATA_03\";\"VAR_DATA_04\";\"VAR_DATA_05\";\"NUM_DATA_01\";\"NUM_DATA_02\";\"NUM_DATA_03\";\"NUM_DATA_04\";\"NUM_DATA_05\";\"FLAG_DATA_01\";\"FLAG_DATA_02\";\"FLAG_DATA_03\";\"FLAG_DATA_04\";\"FLAG_DATA_05\";\"NEWSLETTER_TYPE_01\";\"NEWSLETTER_TYPE_02\";\"NEWSLETTER_TYPE_03\";\"NEWSLETTER_TYPE_04\";\"NEWSLETTER_TYPE_05\";\"INFO_TYPE_01\";\"INFO_TYPE_02\";\"INFO_TYPE_03\";\"INFO_TYPE_04\";\"INFO_TYPE_05\";\"GOLD_QUESTION_01\";\"GOLD_QUESTION_02\";\"GOLD_QUESTION_03\";\"GOLD_QUESTION_04\";\"GOLD_QUESTION_05\";\"GOLD_QUESTION_06\";\"GOLD_QUESTION_07\";\"GOLD_QUESTION_08\";\"GOLD_QUESTION_09\";\"GOLD_QUESTION_10\";\"GOLD_QUESTION_11\";\"GOLD_QUESTION_12\";\"GOLD_QUESTION_13\";\"GOLD_QUESTION_14\";\"GOLD_QUESTION_15\";\"PROFILAZIONE_BRAND\";\"AGE_13\";\"PRIVACY_NES\";\"PRIVACY_NWI\";\"OPTIN_CMZ_BRAND\";\"OPTIN_CMZ_NES_CROSS\";\"OPTIN_CMZ_NWI_CROSS\";\"OPTIN_MOBILE\";\"OPTIN_MOBILE_FASCIA\";\"DATE_DATA_01\";\"DATE_DATA_02\";\"DATE_UPDATE_AGENCY\"\n"
    
    users.each do |user|
      aux = JSON.parse(user.aux)

      csv << "\"WEB\";"
      csv << "\"orzoro\";"
      csv << "\"#{user.id}\";"
      csv << "\"#{user.last_name}\";"
      csv << "\"#{user.first_name}\";"

      csv << build_semicolon(8)

      csv << "\"#{user.email}\";"

      csv << build_semicolon(6)

      day_of_birth = sprintf '%02d', aux["cup_redeem"][0]["identity"]["day_of_birth"]
      month_of_birth = sprintf '%02d', aux["cup_redeem"][0]["identity"]["month_of_birth"]
      year_of_birth = aux["cup_redeem"][0]["identity"]["year_of_birth"]

      csv << "\"#{year_of_birth}#{month_of_birth}#{day_of_birth}\";"

      csv << build_semicolon(7)

      csv << "\"#{user.created_at.to_date.strftime("%Y%m%d")}\";"

      csv << build_semicolon(107)

      csv << "\"1\";" # > 13

      csv << "\"G\";"
      csv << "\"G\";"

      newsletter = compute_terms_or_newsletter_value(aux["cup_redeem"][0]["identity"]["newsletter"])

      csv << "\"#{newsletter}\";"

      terms = compute_terms_or_newsletter_value(aux["cup_redeem"][0]["identity"]["terms"])

      csv << "\"#{terms}\";"
      csv << "\"#{terms}\";"

      csv << "\"N\";"
      csv << "\"N\";"
        
      csv << build_semicolon(2)
      sync_timestamp = Time.now.strftime("%Y%m%d")

      csv << "\"#{sync_timestamp}\"\n"

      aux["sync_timestamp"] = sync_timestamp
      user.update_attribute(:aux, aux.to_json)

    end

    csv.gsub(/\n/,"\r\n") # Windows new line
  end 

  def compute_out(out_path, out_mv_path)
    puts "From #{out_path} to #{out_mv_path}"

    Dir["#{out_path}*.csv"].sort.each do |file|
      File.open(file, "r").each_with_index do |row, index|

        if index > 0

          id_tprov, 
          id_iprov, 
          id_cprov, # user_id
          privacy_nes, 
          privacy_nwi, 
          optin_cmz_brand, 
          optin_cmz_nes_cross, 
          optin_cmz_nwi_cross, 
          optin_mobile = row.gsub("\"", "").split(";")

          user = User.find(id_cprov)

          if user.present?

            puts "#{index} - #{user.email}"

            aux = JSON.parse(user.aux)
            terms = compute_terms_or_newsletter_value(aux["cup_redeem"][0]["identity"]["terms"])

            save_user = false
            
            if terms == "G" && (optin_cmz_nes_cross == "D" || optin_cmz_nwi_cross == "D")
              terms = "-1"
              save_user = true
            elsif terms == "D" && (optin_cmz_nes_cross == "G" && optin_cmz_nwi_cross == "G")
              terms = "1"
              save_user = true
            end

            newsletter = compute_terms_or_newsletter_value(aux["cup_redeem"][0]["identity"]["newsletter"])

            if newsletter == "G" && optin_cmz_brand == "D"
              newsletter = "-1"
              save_user = true
            elsif user.newsletter_for_in_out == "D" && optin_cmz_brand == "G"
              newsletter = "1"
              save_user = true
            end

            if save_user
              aux["terms"] = terms
              aux["cup_redeem"][0]["identity"]["terms"] = terms
              aux["cup_redeem"][0]["identity"]["newsletter"] = newsletter
              aux["sync_timestamp"] = ""

              user.update_attribute(:aux, aux.to_json)
            end

          end

        end

      end

      FileUtils.mv(file, "#{out_mv_path}")

    end
  end

end

