# users_controller.rb
class UsersController < ApplicationController
  skip_before_action :ensure_user_logged_in, except: [:destroy]
  before_action :ensure_owner, only: [:destroy]
  before_action :ensure_not_clerk, only: [:update_profile_view, :update_user]

  def new
    if current_user
      if current_user.role == "customer" || current_user.role == "clerk"
        redirect_to users_menu_path(id: 0)
      end
    end
  end

  def create
    user = User.new(name: params[:name],
                    phone_no: params[:phone_no],
                    email: params[:email],
                    password: params[:password],
                    role: params[:role])

    if user.save
      if (@current_user && @current_user.role == "owner")
        Cart.create!(user_id: user.id) if params[:role] == "clerk"
        redirect_to admin_index_path and return
      end
      session[:current_user_id] = user.id
      Cart.create!(user_id: user.id)
      redirect_to users_menu_path(id: 0)
    else
      flash[:error] = user.errors.full_messages.join(", ")
      redirect_to new_user_path
    end
  end

  def update_profile_view
  end

  def update_user
    user = @current_user
    user.name = params[:name]
    user.phone_no = params[:phone_no]
    user.email = params[:email]
    unless user.save
      flash[:error] = user.errors.full_messages.join(", ")
      redirect_to update_profile_view_path
    else
      if @current_user.role == "owner"
        redirect_to admin_index_path
      else
        redirect_to users_menu_path(id: 0)
      end
    end
  end

  def destroy
    user = User.find(params[:id])
    if user.email != "admin123@gmail.com"
      user.archived_by = true
      user.save!
    end
    redirect_to users_profile_path
  end
end
