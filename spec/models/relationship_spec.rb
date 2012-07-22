require 'spec_helper'

describe Relationship do

  before do
    @follower = FactoryGirl.create(:user)
    @followed = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
    @attr = { :followed_id => @followed.id }
  end

  it "should create a new relationship" do
    @follower.relationships.create!(@attr)
  end

  describe "follow methods" do

    before do
      @relationship = @follower.relationships.create!(@attr)
    end

    it "should have a follower attribute" do
      @relationship.should respond_to(:follower)
    end

    it "should have the right follower" do
      @relationship.follower.should == @follower
    end

    it "should have a followed attribute" do
      @relationship.should respond_to(:followed)
    end

    it "should have the right followed" do
      @relationship.followed.should == @followed
    end

  end

  describe "Validations" do

    before do
        @relationship = @follower.relationships.create!(@attr)
    end

    it "should require a follower id" do
			@relationship.follower_id = nil
			@relationship.should_not be_valid
    end

    it "should require a followed id" do
			@relationship.followed_id = nil
			@relationship.should_not be_valid
    end

  end

end
