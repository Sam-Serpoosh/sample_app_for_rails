class UsersController < ApplicationController
		before_filter :authenticate, :except => [:show, :create, :new]
		before_filter :correct_user, :only => [:edit, :update]
		before_filter :admin_user, :only => :destroy
		before_filter :already_existed_users, :only => [:new, :create]

		def index
				@users = User.paginate(:page => params[:page])
				@title = "All Users"
		end

		def show
				@user = User.find(params[:id])
				@microposts = @user.microposts.paginate(:page => params[:page])
				@title = @user.name
    end

    def following
      @title = "Following"
      @user = User.find(params[:id])
      @users = @user.following.paginate(:page => params[:page])
      render 'show_follow'
    end

    def followers
      @title = "Followers"
      @user = User.find(params[:id])
      @users = @user.followers.paginate(:page => params[:page])
      render 'show_follow'
    end

    def microposts
      user = User.find(params[:id])
      @feed_items = user.microposts.paginate(:page => params[:page])
      render 'show_microposts'
    end

		def new
				@user = User.new
				@title = "Sign up"
		end

		def create
				@user = User.new(params[:user])
				if @user.save
						sign_in @user
						flash[:success] = "Welcome to the Sample APP!"
						redirect_to @user
				else
						@title = "Sign up"
						@user.password = ""
						@user.password_confirmation = ""
						render 'new'
				end
		end

		def edit
				@title = "Edit User"
		end

		def update
				if @user.update_attributes(params[:user])
					redirect_to @user, :flash => { :success => "Profile updated." }
				else
					@title = "Edit User"
					render 'edit'
				end
		end

		def destroy
				@user.destroy
				redirect_to users_path, :flash => { :success => "User destroyed."}
		end

		private
			
			def correct_user
					@user = User.find(params[:id])
					redirect_to(root_path) unless current_user?(@user) 
			end

			def admin_user
					@user = User.find(params[:id])
					redirect_to(root_path) if !current_user.admin? || current_user?(@user)
			end

			def already_existed_users
					redirect_to(root_path) unless !signed_in?
			end

end
