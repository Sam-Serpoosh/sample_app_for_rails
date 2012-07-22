require 'spec_helper'

describe User do

		before do
				@attr = {:name => "Example User", :email => "user@example.com",
						:password => "foobar", :password_confirmation => "foobar"}
		end

		it "should create a new instance given valid attributes" do
				User.create!(@attr)
		end

		it "should require a name" do
				no_name_user = User.new(@attr.merge(:name => ""))
				no_name_user.should_not be_valid
		end

		it "should require an email" do
				no_email_user = User.new(@attr.merge(:email => ""))
				no_email_user.should_not be_valid
		end

		it "should reject names that are too long" do
				long_name = "a" * 51
				long_name_user = User.new(@attr.merge(:name => long_name))
				long_name_user.should_not be_valid
		end

		it "should accept valid email addresses" do
				addresses = %w[user@foo.com THE_USER@foo.bar.org fist.last@foo.jp]
				addresses.each do |address|
						valid_email_user = User.new(@attr.merge(:email => address))
						valid_email_user.should be_valid
				end
		end

		it "should reject invalid email addresses" do
				addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
				addresses.each do |address|
						invalid_email_user = User.new(@attr.merge(:email => address))
						invalid_email_user.should_not be_valid
				end
		end

		it "should reject duplicate email addresses" do
				User.create!(@attr)
				duplicate_email_user = User.new(@attr)
				duplicate_email_user.should_not be_valid
		end

		it "should reject duplicate email address and ignore the case" do
				User.create!(@attr)
				upper_case_email = @attr[:email].upcase
				upper_case_email_user = User.new(@attr.merge(:email => upper_case_email))
				upper_case_email_user.should_not be_valid
		end

		describe "Password Validations" do
				it "should require a password" do
						without_password_user = User.new(@attr.merge(:password => "", :password_confirmation => ""))
						without_password_user.should_not be_valid
				end

				it "should require matching password confirmation" do
						not_matched_password_user = User.new(@attr.merge(:password_confirmation => "invalid"))
						not_matched_password_user.should_not be_valid
				end

				it "should reject short password" do
						short_password = "a" * 5
						short_password_user = User.new(@attr.merge(:password => short_password, :password_confirmation => short_password))
						short_password_user.should_not be_valid
				end

				it "should reject long passwords" do
						long_password = "a" * 41
						long_password_user = User.new(@attr.merge(:password => long_password, :password_confirmation => long_password))
						long_password_user.should_not be_valid
				end
		end

		describe "Password Encryption" do
				before do
						@user = User.create!(@attr)
				end

				it "should have an encrypted password attribute" do
						@user.should respond_to(:encrypted_password)
				end

				it "should set the encrypted password" do
						@user.encrypted_password.should_not be_blank
				end

				describe "has_password? method" do
					it "should be true if the passwords match" do
							@user.has_password?(@attr[:password]).should be_true
					end

					it "should be false if the passwords dont match" do
							@user.has_password?("invalid").should be_false
					end
				end

				describe "authenticate method" do
						it "should return nil on email/password mismatch" do
								wrong_password_user = User.authenticate(@attr[:email], "wrongpassword")
								wrong_password_user.should be_nil
						end

						it "should return nil for an email address with no user" do
								nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
								nonexistent_user.should be_nil
						end

						it "should return the user on email/password match" do
								matching_user = User.authenticate(@attr[:email], @attr[:password])
								matching_user.should == @user
						end
				end
		end

		describe "admin attribute" do

				before do
						@user = User.create!(@attr)
				end

				it "should respond to admin" do
						@user.should respond_to(:admin)
				end

				it "should not be an admin by default" do
						@user.should_not be_admin
				end

				it "should be convertable to admin" do
						@user.toggle!(:admin)
						@user.should be_admin
				end

		end

		describe "micropost association" do

				before do
						@user= User.create(@attr)
						@mp1 = FactoryGirl.create(:micropost, :user => @user, :created_at => 1.day.ago)
						@mp2 = FactoryGirl.create(:micropost, :user => @user, :created_at => 1.hour.ago) 
				end

				it "should have a micropost attribute" do
						@user.should respond_to(:microposts)
				end

				it "should have the right microposts in the right order" do
						@user.microposts.should == [@mp2, @mp1]
				end

				it "should destroy associated microposts" do
						@user.destroy
						[@mp1, @mp2].each do |micropost|
								Micropost.find_by_id(micropost.id).should be_nil
						end
				end

				describe "status feed" do
						it "should have a feed" do
								@user.should respond_to(:feed)
						end

						it "should include user's microposts" do
								@user.feed.include?(@mp1).should be_true
								@user.feed.include?(@mp2).should be_true
						end

						it "should not include different user's microposts" do
								mp3 = FactoryGirl.create(:micropost, :user => FactoryGirl.create(:user, :email => FactoryGirl.generate(:email)))
								@user.feed.should_not include(mp3)
            end

            it "should include the microposts of followed users" do
                followed = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
                mp3 = FactoryGirl.create(:micropost, :user => followed)
                @user.follow!(followed)
                @user.feed.should include(mp3)
            end

				end

    end

    describe "Relationship" do
        before do
          @user = User.create(@attr)
          @followed = FactoryGirl.create(:user)
        end

        it "should have a relationship method" do
          @user.should respond_to(:relationships)
        end

		it "should have following method" do
		  @user.should respond_to(:following)
		end

        it "should have a follow! method" do
          @user.should respond_to(:following)
        end

        it "should follow another user" do
          @user.follow!(@followed)
          @user.should be_following(@followed)
        end

        it "should include the followed user in the following collection" do
          @user.follow!(@followed)
          @user.following.should include(@followed)
        end

        it "should have unfollow! method" do
          @user.should respond_to(:unfollow!)
        end

        it "should be able to unfollow a user" do
          @user.follow!(@followed)
          @user.unfollow!(@followed)
          @user.should_not be_following(@followed)
        end

        it "should have a reverse_relationships method" do
          @user.should respond_to(:reverse_relationships)
        end

        it "should have a followers method" do
          @user.should respond_to(:followers)
        end

        it "should include the follower in the followers collection" do
          @user.follow!(@followed)
          @followed.followers.should include(@user)
        end
    end

end
