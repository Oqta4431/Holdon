class JudgementsController < ApplicationController
  before_action :authenticate_user!

  def index
    @item = current_user.items.ready_for_judgement
                        .with_attached_item_image
                        .order(created_at: :asc)
                        .first
  end

  def update
    item = current_user.items.find(params[:item_id])
    judgement = item.judgement
    status = judgement_params[:purchase_status]

    ## 購入判断の更新、判断時刻の更新、検討中の場合のリマインド時刻の更新を3つセットで行う
    Judgement.transaction do
      judgement.update!(purchase_status: status, decided_at: Time.current)

      if status == "considering"
        # 再検討時：現在のremind_atを履歴としてpast_remindersに保存してから更新する
        item.reminder.past_reminders.create!(past_remind_at: item.reminder.remind_at)

        remind_interval = judgement_params[:remind_interval].to_i
        # 起算点はdecided_at(判断した時刻)
        item.reminder.update!(
          remind_at: judgement.decided_at + remind_interval.seconds,
          remind_interval: remind_interval
        )
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
    params.require(:judgement).permit(:purchase_status, :remind_interval)
  end
end
