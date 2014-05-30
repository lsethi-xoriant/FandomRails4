#!/bin/env ruby
# encoding: utf-8

class ProfileController < ApplicationController
  include ProfileHelper
  include ApplicationHelper

  def complete_for_contest
    unless current_user.update_attributes(params[:user])
      render_error_str =  (render_to_string "/profile/_form_error", locals: { resource: current_user }, layout: false, formats: :html)
    else
      #
    end

    respond_to do |format|
      format.js { render "complete_for_contest", locals: { errors: current_user.errors.any?, render_error_str: render_error_str.to_json }}
    end

  end

  def index
  end

  def remove_provider
  	auth = current_user.authentications.find_by_provider(params[:provider])
  	auth.destroy if auth
  	redirect_to "/profile/edit"
  end

  def rankings

    @triclassifica_all_prop = Hash.new
    if current_user
      Property.active.each do |p|
        @triclassifica_all_prop["#{ p.slug }"] = user_before_and_after p
      end
    end

    @triclassifica_fb_all_prop = Hash.new
    if current_user && current_user.facebook
      Property.active.each do |p|
        @triclassifica_fb_all_prop["#{ p.slug }"] = user_fb_before_and_after p
      end
    end

  end

  def levels
  end

  def badges
  end

  def show
  	if current_user
  		@current_prop = Property.find(params[:property_id])
  	else
  		redirect_to "/#{ @current_prop.slug }"
  	end
  end

  private

  def user_before_and_after current_prop
    ru = RewardingUser.find_by_user_id_and_property_id(current_user.id, current_prop.id)

    if ru
      user_position_current_prop = current_prop.rewarding_users.where("points>=#{ ru.points }").order("points ASC").count # Non conto l'utente corrente.
      user_count_current_prop = current_prop.rewarding_users.count

      triclassifica_current_prop = Hash.new
      if user_position_current_prop == 1 # Sono in prima posizione
        
        triclassifica_current_prop[0] = {
          "id" => ru.user.id,
          "first_name" => ru.user.first_name,
          "last_name" => ru.user.last_name,
          "points" => ru.points,
          "position" => user_position_current_prop
        }

        i = user_position_current_prop + 1
        current_prop.rewarding_users.where("points<#{ ru.points }").order("points DESC").limit(2).each do |u|
          triclassifica_current_prop[i] = {
            "id" => u.user.id,
            "first_name" => u.user.first_name,
            "last_name" => u.user.last_name,
            "points" => u.points,
            "position" => i
          }
          i = i + 1
        end

      elsif user_position_current_prop == user_count_current_prop # Sono in ultima posizione
        
        i = user_count_current_prop - 2
        current_prop.rewarding_users.where("points>=#{ ru.points} AND id<>#{ ru.id}").order("points ASC").limit(2).reverse.each do |u|
          triclassifica_current_prop[i] = {
            "id" => u.user.id,
            "first_name" => u.user.first_name,
            "last_name" => u.user.last_name,
            "points" => u.points,
            "position" => i
          }
          i = i + 1
        end

        triclassifica_current_prop[0] = {
          "id" => ru.user.id,
          "first_name" => ru.user.first_name,
          "last_name" => ru.user.last_name,
          "points" => ru.points,
          "position" => user_count_current_prop
        }

      else # Sono in posizione intermedia
        
        next_user = current_prop.rewarding_users.where("points>=#{ ru.points } AND id<>#{ ru.id }").order("points ASC").limit(1).first
        triclassifica_current_prop[0] = {
          "id" => next_user.user.id,
          "first_name" => next_user.user.first_name,
          "last_name" => next_user.user.last_name,
          "points" => next_user.points,
          "position" => user_position_current_prop - 1
        } if next_user

        triclassifica_current_prop[1] = {
          "id" => ru.user.id,
          "first_name" => ru.user.first_name,
          "last_name" => ru.user.last_name,
          "points" => ru.points,
          "position" => user_position_current_prop
        }

        next_user = current_prop.rewarding_users.where("points<#{ ru.points }").order("points DESC").limit(1).first
        triclassifica_current_prop[2] = {
          "id" => next_user.user.id,
          "first_name" => next_user.user.first_name,
          "last_name" => next_user.user.last_name,
          "points" => next_user.points,
          "position" => user_position_current_prop + 1
        } if next_user
      end 
    end

    return triclassifica_current_prop

  end

  def user_fb_before_and_after current_prop
    ru = RewardingUser.find_by_user_id_and_property_id(current_user.id, current_prop.id)
    current_auth_user_friend_list = current_user.facebook.get_connections("me", "friends").collect { |f| f["id"] }
    #current_user_friend_list = User.where("id in (?)", current_auth_user_friend_list.map.collect { |u| u["id"] })

    if ru
      user_position_current_prop = current_prop.rewarding_users.where("points>=#{ ru.points } AND user_id in (?)", current_auth_user_friend_list.map.collect { |u| u["id"] }).order("points ASC").count + 1 # Non conto l'utente corrente.
      user_count_current_prop = current_prop.rewarding_users.count

      triclassifica_current_prop = Hash.new
      if user_position_current_prop == 1 # Sono in prima posizione
        
        triclassifica_current_prop[0] = {
          "id" => ru.user.id,
          "first_name" => ru.user.first_name,
          "last_name" => ru.user.last_name,
          "points" => ru.points,
          "position" => user_position_current_prop
        }

        i = user_position_current_prop + 1
        current_prop.rewarding_users.where("points<#{ ru.points } AND user_id in (?)", current_auth_user_friend_list.map.collect { |u| u["id"] }).order("points DESC").limit(2).each do |u|
          triclassifica_current_prop[i] = {
            "id" => u.user.id,
            "first_name" => u.user.first_name,
            "last_name" => u.user.last_name,
            "points" => u.points,
            "position" => i
          }
          i = i + 1
        end

      elsif user_position_current_prop == user_count_current_prop # Sono in ultima posizione
        
        i = user_count_current_prop - 2
        current_prop.rewarding_users.where("points>=#{ ru.points} AND id<>#{ ru.id} AND user_id in (?)", current_auth_user_friend_list.map.collect { |u| u["id"] }).order("points ASC").limit(2).reverse.each do |u|
          triclassifica_current_prop[i] = {
            "id" => u.user.id,
            "first_name" => u.user.first_name,
            "last_name" => u.user.last_name,
            "points" => u.points,
            "position" => i
          }
          i = i + 1
        end

        triclassifica_current_prop[0] = {
          "id" => ru.user.id,
          "first_name" => ru.user.first_name,
          "last_name" => ru.user.last_name,
          "points" => ru.points,
          "position" => user_count_current_prop
        }

      else # Sono in posizione intermedia
        
        next_user = current_prop.rewarding_users.where("points>=#{ ru.points } AND id<>#{ ru.id } AND user_id in (?)", current_auth_user_friend_list.map.collect { |u| u["id"] }).order("points ASC").limit(1).first
        triclassifica_current_prop[0] = {
          "id" => next_user.user.id,
          "first_name" => next_user.user.first_name,
          "last_name" => next_user.user.last_name,
          "points" => next_user.points,
          "position" => user_position_current_prop - 1
        } if next_user

        triclassifica_current_prop[1] = {
          "id" => ru.user.id,
          "first_name" => ru.user.first_name,
          "last_name" => ru.user.last_name,
          "points" => ru.points,
          "position" => user_position_current_prop
        }

        next_user = current_prop.rewarding_users.where("points<#{ ru.points } AND user_id IN (?)", current_auth_user_friend_list.map.collect { |u| u["id"] }).order("points DESC").limit(1).first
        triclassifica_current_prop[2] = {
          "id" => next_user.user.id,
          "first_name" => next_user.user.first_name,
          "last_name" => next_user.user.last_name,
          "points" => next_user.points,
          "position" => user_position_current_prop + 1
        } if next_user
      end 
    end

    return triclassifica_current_prop

  end
end
