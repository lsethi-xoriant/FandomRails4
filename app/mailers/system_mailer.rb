#!/bin/env ruby
# encoding: utf-8

class SystemMailer < ActionMailer::Base

  def share_interaction(user, to, calltoaction, aux = {})
    @cuser = user
    @calltoaction = calltoaction
    @aux = aux
    subject = @aux.has_key?(:subject) ? @aux[:subject] : $site.title
    mail(to: to, subject: "#{subject} - Un tuo amico ti ha condiviso un contenuto")
  end

  def welcome_mail(user)
    @cuser = user

    mail(to: user.email, subject: "Benvenuto!")
  end

  def welcome_mail_braun(user)
    mail(to: user.email, subject: "Benvenuto!")
  end

  def win_mail(user, reward, ticket_id, request)
    subject = Rails.configuration.deploy_settings["sites"][get_site_from_request(request)["id"]]["title"] rescue ""
    @reward = reward
  	@cuser = user
  	@ticket_id = ticket_id

  	mail(to: user.email, bcc: 'contestfandom@gmail.com', subject: "#{subject} - Hai vinto #{@reward.title}")
  end

  def braun_win_mail(user)
    @full_name = "#{user.first_name} #{user.last_name}"

    mail(to: user.email, subject: "Hai vinto un Minipimer!")
  end

  def braun_recipe_mail(user, product_hash)
    @full_name = "#{user.first_name} #{user.last_name}"
    @product = product_hash

    mail(to: user.email, subject: "Il tuo scontrino è stato registrato")
  end

  def win_admin_notice_mail(user, reward, ticket_id, request)
    subject = Rails.configuration.deploy_settings["sites"][get_site_from_request(request)["id"]]["title"]
    @reward = reward
  	@cuser = user
  	@ticket_id = ticket_id

  	mail(to: [ "", "concorsi@shado.tv" ], subject: "#{subject} - #{@reward.title}")
  end

  def notification_mail(email, html_message, subject)
    @body = html_message
    mail(to: email, subject: subject)
  end
  
  def orzoro_cup_redeem_confirmation(cup_obj)
    subject = "Congratulazioni! Hai ordinato le tazze"
    @form_cup = cup_obj
    @cup_tag_extra_fields = get_extra_fields!(Tag.find_by_name("cup-redeemer"))
    @assets_extra_fields = get_extra_fields!(Tag.find_by_name("assets"))
    if @form_cup['receipt']['package_count'].to_i == 2
      @packages_image_url = @cup_tag_extra_fields["two_packages"]["url"] rescue nil
      @gadgets_image_url = @cup_tag_extra_fields["placemat"]["url"] rescue nil
    elsif @form_cup['receipt']['package_count'].to_i == 3
      @packages_image_url = @cup_tag_extra_fields["three_packages"]["url"] rescue nil
      if @form_cup['receipt']['cup_selected'] == "placemat_and_miss_tressy"
        @gadgets_image_url = @cup_tag_extra_fields["miss_tressy_cup"]["url"] rescue nil
      elsif @form_cup['receipt']['cup_selected'] == "placemat_and_dora"
        @gadgets_image_url = @cup_tag_extra_fields["dora_cup"]["url"] rescue nil
      else
        @gadgets_image_url = @cup_tag_extra_fields["placemats"]["url"] rescue nil
      end
    else
      @packages_image_url = @cup_tag_extra_fields["five_packages"]["url"] rescue nil
      @gadgets_image_url = @cup_tag_extra_fields["two_cups"]["url"] rescue nil
    end
    mail(to: cup_obj['identity']['email'], subject: subject)
  end

  def orzoro_newsletter_confirmation(info)
    subject = "Congratulazioni! Sei iscritto alla newsletter di Orzoro!"
    @info = info
    @assets_extra_fields = get_extra_fields!(Tag.find_by_name("assets"))
    mail(to: info[:email], subject: subject)
  end

  def orzoro_registration_confirmation_from_cups(cup_obj, user)
    subject = "Conferma il tuo indirizzo mail!"
    @form_cup = cup_obj
    @cup_tag_extra_fields = get_extra_fields!(Tag.find_by_name("cup-redeemer"))
    @assets_extra_fields = get_extra_fields!(Tag.find_by_name("assets"))
    if @form_cup['receipt']['package_count'].to_i == 2
      @packages_image_url = @cup_tag_extra_fields["two_packages"]["url"] rescue nil
      @gadgets_image_url = @cup_tag_extra_fields["placemat"]["url"] rescue nil
    elsif @form_cup['receipt']['package_count'].to_i == 3
      @packages_image_url = @cup_tag_extra_fields["three_packages"]["url"] rescue nil
      if @form_cup['receipt']['cup_selected'] == "placemat_and_miss_tressy"
        @gadgets_image_url = @cup_tag_extra_fields["miss_tressy_cup"]["url"] rescue nil
      elsif @form_cup['receipt']['cup_selected'] == "placemat_and_dora"
        @gadgets_image_url = @cup_tag_extra_fields["dora_cup"]["url"] rescue nil
      else
        @gadgets_image_url = @cup_tag_extra_fields["placemats"]["url"] rescue nil
      end
    else
      @packages_image_url = @cup_tag_extra_fields["five_packages"]["url"] rescue nil
      @gadgets_image_url = @cup_tag_extra_fields["two_cups"]["url"] rescue nil
    end
    @link = "#{root_url}complete_registration_from_cups/#{user.email}/#{user.confirmation_token}"
    mail(to: cup_obj['identity']['email'], subject: subject)
  end

  def orzoro_registration_confirmation_from_newsletter(info, user)
    subject = "Conferma il tuo indirizzo mail!"
    @info = info
    @assets_extra_fields = get_extra_fields!(Tag.find_by_name("assets"))
    @link = "#{root_url}complete_registration_from_newsletter/#{user.email}/#{user.confirmation_token}"
    mail(to: info[:email], subject: subject)
  end

  def send_approved_comments_mail(emails, tenant, days, body, mail_subject = nil)
    to = emails.split(" ")
    subject = mail_subject || "Report commenti approvati negli ultimi #{ days } giorni su #{ tenant.capitalize }"
    @body = body
    mail(to: to, subject: subject)
  end

end
