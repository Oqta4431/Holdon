class JudgementsController < ApplicationController
  before_action :authenticate_user!

  def index
    @item = current_user.items.ready_for_judgement.order(created_at: :asc).first
  end

  def update
    item = current_user.items.find(params[:item_id])
    judgement = item.judgement
    status = judgement_params[:purchase_status]

    ## 購入判断の更新、判断時刻の更新、検討中の場合のリマインド時刻の更新を3つセットで行う
    Judgement.transaction do
      judgement.update!(purchase_status: status, decided_at: Time.current)

      if status == "considering"
        item.reminder.update!(remind_at: Time.current + REMIND_INTERVAL)
      end
      ## purchased / skipped の場合はリマインド時刻は更新しない
    end

    ## 判断画面へ遷移 → 次の一件を取得して表示 → ステータス更新 → 判断画面へ遷移
    ## 判断対象がなくなるまでループする
    redirect_path = params[:redirect_to].presence
    redirect_to redirect_path, notice: "購入判断を更新しました"
  end

  private

  def judgement_params
    params.require(:judgement).permit(:purchase_status)
  end
end
