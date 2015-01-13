#!/bin/env ruby
# encoding: utf-8

class Sites::Disney::RegistrationsController < RegistrationsController

  def iur
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
      hash["Envelope"]["Body"]["retrieveResponse"]["retrieveReturn"]["attributes"]["item"].each do |key, value|
        if key["key"] == "EMAIL_ADDRESS"
          password = Devise.friendly_token.first(8)
          user = User.find_by_email(key["value"])
          if user
            user.update_attribute(:swid, cookies[:SWID])
          else
            user = User.create(email: key["value"], swid: cookies[:SWID], password: password, password_confirmation: password)
          end
        end
      end
    end

    if user.errors.any?
      flash[:errors] = user.errors.full_messages.join(", ")
    else
      sign_in(user)   
    end

    redirect_to cookies[:from_iur_authenticate]

    cookies.delete :BLUE
    cookies.delete :SWID
  end

end
