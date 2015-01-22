#!/bin/env ruby
# encoding: utf-8

class Sites::Disney::RegistrationsController < RegistrationsController

  def update
    user_params = params[:user]
    required_attrs = ["username", "username_length"]
    params[:user] = user_params.merge(required_attrs: required_attrs)

    super
  end

  def iur
    unless cookies[:SWID] && cookies[:SWID]
      from_iur_authenticate = cookies[:from_iur_authenticate]
      cookies.delete :from_iur_authenticate

      flash[:notice] = "from-disney-registration"
      redirect_to from_iur_authenticate
      return
    end

    user = User.find_by_swid(cookies[:SWID])
    unless user
      uri = URI.parse("http://registrazione.disneychannel.it/iur3/services/Login")
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body =
          "<?xml version=\"1.0\" encoding=\"utf-8\" ?>" +
          "<soapenv:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:web=\"http://web.service.iur.intl.wdig.com\" xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\">" +
          "<soapenv:Header>" +
          "<sitecode xsi:type=\"xsd:string\">IT.IT.DIS</sitecode>" +
          "<BLUE xsi:type=\"soapenc:string\">#{ cookies[:BLUE] }</BLUE>" +
          "<SWID soapenv:actor=\"http://schemas.xmlsoap.org/soap/actor/next\" soapenv:mustUnderstand=\"0\" xsi:type=\"soapenc:string\" xmlns:soapenc=\"http://schemas.xmlsoap.org/soap/encoding/\">#{ cookies[:SWID] }</SWID>" +
          "</soapenv:Header>" +
          "<soapenv:Body>" +
          "<web:retrieve soapenv:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">" +
          "</web:retrieve>" +
          "</soapenv:Body>" +
          "</soapenv:Envelope>"
      header = { 'Host' => uri.host, 'Content-Length'=>'740', 'Content-Type' =>'text/xml; charset=utf-8','SOAPAction' => 'loginByEmail'}
      request.initialize_http_header(header)
      response = http.request(request)
      hash = Hash.from_xml response.body

      hash_items = hash["Envelope"]["Body"]["retrieveResponse"]["retrieveReturn"]["attributes"]["item"]

      password = Devise.friendly_token.first(8)
      
      hash_user = {}
      hash_items.each do |key, value|
        hash_user[key["key"]] = key["value"]
      end

      user = User.find_by_email(hash_user["EMAIL_ADDRESS"])
      aux = { 
        "profile_completed" => false, 
        "membername" => hash_user["MEMBERNAME"] 
      }.to_json

      if user
        user.update_attributes(swid: cookies[:SWID], aux: aux)
      else
        user = User.create(email: hash_user["EMAIL_ADDRESS"], swid: cookies[:SWID], password: password, password_confirmation: password, first_name: hash_user["FIRST_NAME"], last_name: hash_user["LAST_NAME"], aux: aux)
      end

    end

    if user.errors.any?
      flash[:errors] = user.errors.full_messages.join(", ")
    else
      sign_in(user)   
    end

    from_iur_authenticate = cookies[:from_iur_authenticate]

    cookies.delete :from_iur_authenticate
    cookies.delete :BLUE, domain: ".disneychannel.it"
    cookies.delete :SWID, domain: ".disneychannel.it"

    redirect_to from_iur_authenticate
  end

end

