class ItemsController < ApplicationController
  before_action :authenticate_user!

  def index
    @items = current_user.items.order(created_at: :desc)
  end

  def new
    @item = Item.new
  end

  def create
    @item = current_user.items.build(item_params)
    if @item.save
      redirect_to items_path, success: "商品を追加しました"
    else
      flash.now[:error] = "商品を追加出来ませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :price)
  end
end
