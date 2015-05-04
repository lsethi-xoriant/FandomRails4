class Easyadmin::UserController < Easyadmin::EasyadminController
  include EasyadminHelper
  include DateMethods
  include FilterHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    authorize! :read, :users
  end

  def index_user
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @user_list = User.page(page).per(per_page)

    @page_size = @user_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def show_user
    @user = User.find(params[:id])
  end
  
  def export_users
    csv = "id;email;remember_created_at;sign_in_count;current_sign_in_at;last_sign_in_at;"+
        "current_sign_in_ip;last_sign_in_ip;first_name;last_name;avatar_selected;swid;privacy;confirmation_token;confirmed_at;confirmation_sent_at;"+
        "unconfirmed_email;role;authentication_token;created_at;updated_at;avatar_file_name;avatar_content_type;avatar_file_size;avatar_updated_at;"+
        "cap;location;province;address;phone;number;rule;birth_date;username;newsletter;avatar_selected_url;aux;gender\n"
    User.all.each do |user|
    csv << "#{user.id};#{user.email};#{user.remember_created_at};"+
            "#{user.sign_in_count};#{user.current_sign_in_at};#{user.last_sign_in_at};#{user.current_sign_in_ip};#{user.last_sign_in_ip};#{user.first_name};"+
            "#{user.last_name};#{user.avatar_selected};#{user.swid};#{user.privacy};#{user.confirmation_token};#{user.confirmed_at};#{user.confirmation_sent_at};"+
            "#{user.unconfirmed_email};#{user.role};#{user.authentication_token};#{user.created_at};#{user.updated_at};#{user.avatar_file_name};"+
            "#{user.avatar_content_type};#{user.avatar_file_size};#{user.avatar_updated_at};#{user.cap};#{user.location};#{user.province};#{user.address};"+
            "#{user.phone};#{user.number};#{user.rule};#{user.birth_date};#{user.username};#{user.newsletter};#{user.avatar_selected_url};#{user.aux};#{user.gender}\n"
    end
    send_data(csv, :type => 'text/csv; charset=utf-8; header=present', :filename => "users.csv")
  end

  def filter_user
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20
    @user_list = User.page(page).per(per_page)

    @email_filter = params[:email_filter]
    @username_filter = params[:username_filter]

    if params[:commit] == "APPLICA FILTRO"
      where_conditions = "true"
      where_conditions << " AND email ILIKE '%#{@email_filter}%'" unless @email_filter.blank?
      where_conditions << " AND username ILIKE '%#{@username_filter}%'" unless @username_filter.blank?

      @user_list = User.where(where_conditions).page(page).per(per_page)
    else
      @email_filter = nil
      @username_filter = nil
    end

    @page_size = @user_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)

    render template: "/easyadmin/easyadmin/index_user" 
  end

end