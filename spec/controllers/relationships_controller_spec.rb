require 'spec_helper'

describe RelationshipsController do

  describe "access control" do

    it "should require signin for create" do
      post :create
      response.should redirect_to(signin_path)
    end

    it "should require signin for destroy" do
      post :destroy, :id => 1
      response.should redirect_to(signin_path)
    end

  end

  describe "POST 'create'" do

    before do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
      @followed = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
    end

    it "should create a relationship" do
      lambda do
        post :create, :relationship => {:followed_id => @followed.id}
        response.should redirect_to(user_path(@followed))
      end.should change(Relationship, :count).by(1)
    end

    #it "should create a relationship with Ajax" do
    #  lambda do
    #    xhr :post, :create, :relationship => { :followed_id => @followed.id }
    #    response.should be_success
    #  end.should change(Relationship, :count).by(1)
    #end

  end

  describe "DELETE 'destroy'" do

    before do
      @user = FactoryGirl.create(:user)
      test_sign_in(@user)
      @followed = FactoryGirl.create(:user, :email => FactoryGirl.generate(:email))
      @user.follow!(@followed)
      @relationship = @user.relationships.find_by_followed_id(@followed)
    end

    it "should destroy a relationship" do
      lambda do
        delete :destroy, :id => @relationship
        response.should redirect_to(user_path(@followed))
      end.should change(Relationship, :count).by(-1)
    end

    #it "should destroy a relationship with Ajax" do
    #  lambda do
    #    xhr :delete, :destroy, :id => @relationship
    #    response.should be_success
    #  end.should change(Relationship, :count).by(-1)
    #end

  end

end
