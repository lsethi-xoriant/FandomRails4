class Sites::BraunIc::Easyadmin::UserController < Easyadmin::EasyadminController
  include EasyadminHelper
  include DateMethods
  include FilterHelper
  include OrzoroHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    authorize! :read, :users
  end

  def export_users
    header = "id;email;first_name;last_name;birth_date;newsletter"
    aux_keys = get_aux_keys()
    header += aux_keys.any? ? ";#{aux_keys.to_a.join(';')}\n" : "\n"
    rows = ""
    User.all.each do |user|
      if user.anonymous_id.nil?
        rows << build_user_row(user, aux_keys)
      end
    end
    send_data(header + rows, :type => 'text/csv; charset=utf-8; header=present', :filename => "braun_users.csv")
  end

  def get_aux_keys()
    keys = Set.new
    User.all.each do |user|
      if user.aux
        user.aux.keys.each do |key|
          keys.add(key) if key != "products"
        end
      end
    end
    keys.add("products")
    keys
  end

  def build_user_row(user, aux_keys)
    user_aux = user.aux || {}
    row = "#{user.id};#{user.email};#{user.first_name};#{user.last_name};#{user.birth_date};#{user.newsletter}"
    aux_keys.each do |key|
      value = user_aux[key]
      if value.is_a? Array
        value.each do |entry|
          if entry.is_a? Hash
            entry.each_with_index do |(k, v), i|
              row += i == 0 ? ";#{k}: #{v}" : ", #{k}: #{v}"
            end
          else
            row += ";#{entry}"
          end
        end
      else
        row += ";#{value}"
      end
    end
    row += "\n"
  end

end