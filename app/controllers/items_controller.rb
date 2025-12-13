class ItemsController < ApplicationController
  before_action :authenticate_user!

  def index
    @items = current_user.items.order(created_at: :desc)
  end

  def new
    @item = Item.new
  end
end
