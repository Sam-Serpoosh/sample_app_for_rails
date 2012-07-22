require 'spec_helper'

describe UsersController do

		render_views

		describe "GET 'index'" do
				describe "for non signed-in users" do
						it "should deny access" do
								get :index
								response.should redirect_to(signin_path)
						end
				end

				describe "for signed-in users" do
						before do
								@user = FactoryGirl.create(:user)
								test_sign_in(@user)
								FactoryGirl.create(:user, :email => "another@example.com")
								FactoryGirl.create(:user, :email => "another@example.net")
								30.times do
										FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
								end
						end

						it "should be successful" do
								get :index
								response.should be_success
						end

						it "should have the right title" do
								get :index
								response.should have_selector("title", :content => "All Users")
						end

						it "should have an element for each user" do
								get :index
								User.paginate(:page => 1).each do |user|
										response.should have_selector("li", :content => user.name)
								end
						end

						it "should paginate users" do
								get :index
								response.should have_selector("div.pagination")
								response.should have_selector("span.disabled", :content => "Previous")
								response.should have_selector("a", :href => "/users?page=2", :content => "2")
						end

						it "should not have delete link for non-admin users" do
								get :index
								response.should_not have_selector("a", :href => user_path(@user), :content => "delete")
						end

						it "should have delete links for admins" do
								@user.toggle!(:admin)
								other_user = User.all.second
								get :index
								response.should have_selector("a", :href => user_path(other_user), :content => "delete")
								response.should have_selector("span", :content => "|")

						end
				end
		end

		describe "GET 'new'" do

				it "should be successful" do
						get :new
						response.should be_success
				end

				it "should have the right title" do
						get :new
						response.should have_selector('title', :content => "Sign up")
				end

				it "should have name field" do
						get :new
						response.should have_selector("input[name='user[name]'][type='text']")
				end

				it "should have email field" do
						get :new
						response.should have_selector("input[name='user[email]'][type='text']")
				end

				it "should have password field" do
						get :new
						response.should have_selector("input[name='user[password]'][type='password']")
				end

				it "should have password confirmation field" do
						get :new
						response.should have_selector("input[name='user[password_confirmation]'][type='password']")
				end

				it "should redirect signed users to root path" do
						user = FactoryGirl.create(:user)
						test_sign_in(user)
						get :new
						response.should redirect_to(root_path)
				end

		end

		describe "GET 'show'" do

				before do
						@user = FactoryGirl.create(:user)
				end

				it "should be successful" do
						get :show, :id => @user
						response.should be_success
				end

				it "should find the right user" do
						get :show, :id => @user
						assigns(:user).should == @user
				end

				it "should have the right title" do
						get :show, :id => @user
						response.should have_selector("title", :content => @user.name)
				end

				it "should contain user name" do
						get :show, :id => @user
						response.should have_selector("h1", :content => @user.name)
				end

				it "should have user profile image" do
						get :show, :id => @user
						response.should have_selector("h1>img", :class => "gravatar")
				end

				it "should show the user's microposts" do
						mp1 = FactoryGirl.create(:micropost, :user => @user, :content => "Foo bar")
						mp2 = FactoryGirl.create(:micropost, :user => @user, :content => "Baz quux")
						get :show, :id => @user
						response.should have_selector("span.content", :content => mp1.content)
						response.should have_selector("span.content", :content => mp2.content)
				end

				it "should paginate microposts" do
						35.times { FactoryGirl.create(:micropost, :user => @user, :content => "foo bar") }
						get :show, :id => @user
						response.should have_selector("div.pagination")
				end

				it "should display the micropost count" do
						10.times { FactoryGirl.create(:micropost, :user => @user, :content => "foo bar") }
						get :show, :id => @user
						response.should have_selector('td.sidebar', :content => @user.microposts.count.to_s)
        end

      describe "when signed in as another user" do
        it "should be successful" do
          user = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
          test_sign_in(user)
          get :show, :id => @user
          response.should be_success
        end
      end

		end

		describe "POST 'create'" do
				describe "failure" do
						before do
								@attr = {:name => "", :email => "", :password => "", :password_confirmation => ""}
						end

						it "should not create a user" do
								lambda do
										post :create, :user => @attr
								end.should_not change(User, :count)
						end

						it "should have the right title" do
								post :create, :user => @attr
								response.should have_selector("title", :content => "Sign up")
						end

						it "should render the 'new' page" do
								post :create, :user => @attr
								response.should render_template('new')
						end

						it "should redirec_to root path signed-in users" do
								user = FactoryGirl.create(:user)
								test_sign_in(user)
								post :create, :user => @attr
								response.should redirect_to(root_path)
						end
				end

				describe "success" do
						before do
								@attr = {:name => "New User", :email => "user@example.com", :password => "foobar", :password_confirmation => "foobar"}
						end

						it "should create user" do
								lambda do
								post :create, :user => @attr
								end.should change(User, :count).by(1)
						end

						it "should redirect to user show page" do
								post :create, :user => @attr
								response.should redirect_to(user_path(assigns(:user)))
						end

						it "should have welcome message" do
								post :create, :user => @attr
								flash[:success].should =~ /welcome to the sample app/i
						end

						it "should sign the user in" do
								post :create, :user => @attr
								controller.should be_signed_in
						end
				end
		end

		describe "GET 'edit'" do
	
				before do
						@user = FactoryGirl.create(:user)
						test_sign_in(@user)
				end

				it "should be successful" do
						get :edit, :id => @user
						response.should be_success
				end

				it "should have the right title" do
						get :edit, :id => @user
						response.should have_selector("title", :content => "Edit User")
				end

				it "should have a link to change the gravatar" do
						get :edit, :id => @user
						response.should have_selector("a", :href => "http://gravatar.com/emails",
													  	   :content => "change")
				end

		end

		describe "PUT 'update'" do
				before do
						@user = FactoryGirl.create(:user)
						test_sign_in(@user)
				end

				describe "failure" do
						before do
								@attr = {:name => "", :email => "", :password => "", :password_confirmation => ""}
						end

						it "should render the 'edit' page" do
								put :update, :id => @user, :user => @attr
								response.should render_template('edit')
						end

						it "should have the right title" do
								put :update, :id => @user, :user => @attr
								response.should have_selector("title", :content => "Edit User")
						end
				end

				describe "success" do
						before do
								@attr = {:name => "New Name", :email => "user@example.org", :password => "barbaz", :password_confirmation => "barbaz"}
						end

						it "should change user's attributes" do
								put :update, :id => @user, :user => @attr
								user = assigns(:user)
								@user.reload
								@user.name.should == "New Name" 
								@user.email.should == "user@example.org"
								@user.encrypted_password.should == user.encrypted_password 
						end

						it "should have a flash message" do
								put :update , :id => @user, :user => @attr
								flash[:success].should =~ /updated/
						end
				end
		end

		describe "authentication of edit/update action" do

				before do
						@user = FactoryGirl.create(:user)
				end	

				describe "for non signed in users" do
						it "should deny access to 'edit'" do
								get :edit, :id => @user
								response.should redirect_to(signin_path)
								flash[:notice].should =~ /sign in/i
						end

						it "should deny access to 'update'" do
								put :update, :id => @user, :user => {}
								response.should redirect_to(signin_path)
						end
				end

				describe "for signed in users" do
						before do
								wrong_user = FactoryGirl.create(:user, :email => "user@example.net")
								test_sign_in(wrong_user)
						end

						it "should require matching users for 'edit'" do
								get :edit, :id => @user
								response.should redirect_to(root_path)
						end

						it "should require matching users for 'update'" do
								put :update, :id => @user, :user => {}
								response.should redirect_to(root_path)
						end
				end
		end

		describe "DELETE 'destroy" do
				before do
						@user = FactoryGirl.create(:user)
				end

				describe "as a non-signed-in user" do
						it "should deny access" do
								delete :destroy, :id => @user
								response.should redirect_to(signin_path)
						end
				end

				describe "as non-admin user" do
						it "should protect the action" do
								test_sign_in(@user)
								delete :destroy, :id => @user
								response.should redirect_to(root_path)
						end
				end

				describe "as admin user" do

						before do
								@admin = FactoryGirl.create(:user, :email => "admin@example.com", :admin => true)
								test_sign_in(@admin)
						end

						it "should destroy the user" do
								lambda do
										delete :destroy, :id => @user
								end.should change(User, :count).by(-1)
						end

						it "should redirect to users page" do
								delete :destroy, :id => @user
								flash[:success].should =~ /destroyed/i
								response.should redirect_to(users_path)
						end

						it "should not be able to delete him/her self" do
								lambda do
									delete :destroy, :id => @admin
								end.should_not change(User, :count)
						end
				end
    end

    describe "follow pages" do
      describe "when not signed-in" do

        it "should protect 'following'" do
          get :following, :id => 1
          response.should redirect_to(signin_path)
        end

        it "should protect 'followers'" do
          get :followers, :id => 1
          response.should redirect_to(signin_path)
        end

      end

      describe "when signed in" do

        before do
          @user = FactoryGirl.create(:user)
          test_sign_in(@user)
          @other_user = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
          @user.follow!(@other_user)
        end

        it "should show user following" do
          get :following, :id => @user
          response.should have_selector("a", :href => user_path(@other_user),
                                             :content => @other_user.name)
        end

        it "Should show user followers" do
          get :followers, :id => @other_user
          response.should have_selector("a", :href => user_path(@user),
                                             :content => @user.name)
        end

      end
    end

    describe "microposts page" do
      
      describe "when not signed-in" do

        it "should protect 'microposts'" do
          get :microposts, :id => 1
          response.should redirect_to(signin_path)
        end

      end

      describe "when signed-in" do

        before do
          @user = FactoryGirl.create(:user)
          test_sign_in(@user)
          @mp1 = FactoryGirl.create(:micropost, :user => @user)
        end

        it "should show user's microposts" do
          get :microposts, :id => @user
          response.should have_selector("span", :content => @mp1.content)
          response.should have_selector("span", :content => "ago")
        end

        it "should not show other users microposts" do
          @other_user = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
          mp2 = FactoryGirl.create(:micropost, :content => "Other Post", :user => @other_user)
          get :microposts, :id => @user
          response.should_not have_selector("span", :content => mp2.content)
        end
        
      end

    end

end
