class Easyadmin::TagController < ApplicationController
  include EasyadminHelper

  layout "admin"

  def index
    @tags = Tag.all
  end

  def new
    @tag = Tag.new
  end

  def save
    
  end

  def edit
    
  end
  
  def update
    
  end

end