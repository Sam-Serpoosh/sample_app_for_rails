class RelationshipsController < ApplicationController

  before_filter :authenticate

  def create
    @followed_user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@followed_user)
    #respond_to do |format|
    #  format.html { redirect_to @followed_user } #one of these two lines will be executed
    #  format.js
    #end
    redirect_to @followed_user
  end

  def destroy
    #relationship = Relationship.find(params[:id]).destroy  one style
    @followed_user = Relationship.find(params[:id]).followed  # another style for more symmetry with create
    current_user.unfollow!(@followed_user)
    #respond_to do |format|
    #  format.html { redirect_to @followed_user } #one of these two lines will be executed
    #  format.js
    #end
    redirect_to @followed_user
  end

end