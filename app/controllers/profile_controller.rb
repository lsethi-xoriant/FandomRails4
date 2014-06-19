#!/bin/env ruby
# encoding: utf-8

class ProfileController < ApplicationController
  include ProfileHelper
  include ApplicationHelper

  def index
  end

  def remove_provider
  	auth = current_user.authentications.find_by_provider(params[:provider])
  	auth.destroy if auth
  	redirect_to "/profile/edit"
  end

  def rankings
  end

  def levels
    # TODO: adjust.
  end

  def badges
    # TODO: adjust.
  end

  def show
  end

end
