require 'spec_helper'

describe "Users" do

		describe "signup" do

				describe "failure" do

						it "should not make a new user with invald signup data" do
								lambda do
										visit signup_path
										fill_in "Name", :with => ""
										fill_in "Email", :with => ""
										fill_in "Password", :with => ""
										fill_in "Confirmation", :with => ""
										click_button
										response.should render_template("users/new")
										response.should have_selector("div#error_explanation")
								end.should_not change(User, :count)
						end

				end

				describe "success" do
						it "should make a new user for valid signup data" do
								lambda do
										visit signup_path
										fill_in "Name", :with => "Example User"
										fill_in "Email", :with => "user@exaple.com"
										fill_in "Password", :with => "foobar"
										fill_in "Confirmation", :with => "foobar"
										click_button
										response.should render_template("users/show")
										response.should have_selector("div.flash.success", :content => "Welcome")
								end.should change(User, :count).by(1)
						end
				end

		end

		describe "signin" do
				describe "failure" do
						it "should not sign a user in" do
								user = User.new(:name => "invalid user", :email => "", :password => "", :password_confirmation => "")
								integration_sign_in(user)
								response.should have_selector("div.flash.error", :content => "Invalid")
								response.should render_template('sessions/new')
						end
				end

				describe "success" do
						it "should sign a user in and out" do
                visit root_path 
								user = FactoryGirl.create(:user)
								integration_sign_in(user)
                response.should have_selector("h1", :content => user.name)
								click_link "Sign out"
                response.should have_selector("p", :content => "home page")
						end
				end
		end

end
