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

    # remind_intervalはフォームのhiddenフィールドから秒単位で受け取る
    # 起算点はcreated_at（登録時刻）だが、saveが完了しないとcreated_atが確定しないため
    # saveのコールバックとしてafter_createで設定する代わりに、
    # ここでは仮にTime.currentを使い、save後にcreated_atに基づいて再計算する
    # → 簡略化のため、saveが呼ばれる瞬間のTime.currentをcreated_atの近似値として使う
    remind_interval = remind_interval_param
    @item.build_reminder(
      remind_at: Time.current + remind_interval.seconds,
      remind_interval: remind_interval_param
    )

    if @item.save
      # save完了後、created_atが確定するのでremind_atをcreated_atから再計算して更新する
      @item.reminder.update!(remind_at: @item.created_at + remind_interval.seconds)
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
      # 編集時はTime.currentを起算点としてremind_atを再計算する
      remind_interval = remind_interval_param
      @item.reminder.update!(
        remind_at: Time.current + remind_interval.seconds,
        remind_interval: remind_interval_param
      )
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
    # Item モデルの属性のみを許可する（remind_interval は reminders テーブルのカラムのため含めない）
    params.require(:item).permit(:name, :price, :url, :memo, :item_image)
  end

  def remind_interval_param
    # フォームの hidden フィールドから秒単位で受け取る（item ネストで送られてくる）
    params.dig(:item, :remind_interval).to_i
  end

  def set_item
    @item = current_user.items.find(params[:id])
  end
end
