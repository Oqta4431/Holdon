class ItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item, only: %i[show edit update destroy]

  def index
    allowed_statuses = %w[considering purchased skipped]

    # デフォルトとして "considering" を採用
    if allowed_statuses.include?(params[:status])
      @status = params[:status]
    else
      @status = "considering"
    end

    base_scope = current_user.items
                              .includes(:judgement)
                              .with_attached_item_image
                              .joins(:judgement)
                              .where(judgements: { purchase_status: @status })

    # 検討中：登録日順
    # 購入/見送り：判断をした日
    if @status == "considering"
      @items = base_scope.order(created_at: :desc)
    else
      @items = base_scope.order("judgements.decided_at DESC")
    end
  end

  def show
    @reason = @item.reason || @item.build_reason
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
    params.require(:item).permit(:name, :price, :url, :memo, :item_image)
  end

  def set_item
    @item = current_user.items.find(params[:id])
  end
end
