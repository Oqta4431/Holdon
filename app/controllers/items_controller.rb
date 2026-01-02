class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: %i[show edit update destroy]

  def index
    @items = current_user.items.order(created_at: :desc)
  end

  def show
  end

  def new
    @item = Item.new
  end

  def create
    @item = current_user.items.build(item_params)
    @item.build_judgement(purchase_status: :considering)
    ## REMIND_INTERVAL
    ## dev環境では1min, それ以外では24h
    ## ⚠️MVP用、本リリで任意の間隔でリマインド出来るように改良する⚠️
    @item.build_reminder(remind_at: Time.current + REMIND_INTERVAL)
    if @item.save
      redirect_to items_path, success: "商品を追加しました"
    else
      flash.now[:error] = "商品を追加出来ませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @item.update(item_params)
      redirect_to item_path(@item), success: "商品を編集しました"
    else
      flash.now[:error] = "商品を編集できませんでした"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy!
    redirect_to items_path, success: "商品を削除しました"
  end

  private

  def item_params
    params.require(:item).permit(:name, :price, :url, :memo)
  end

  def set_item
    @item = current_user.items.find(params[:id])
  end
end
