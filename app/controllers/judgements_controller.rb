class JudgementsController < ApplicationController
  before_action :authenticate_user!

  def update
    item = current_user.items.find(params[:item_id])
    ## judgementがnilだった場合、consideringとして登録しておく
    judgement = item.judgement || item.create_judgement!(purchase_status: :considering)

    judgement.update!(
      purchase_status: judgement_params[:purchase_status],
      decided_at: Time.current
    )

    redirect_to item_path(item), notice: "購入判断を更新しました"
  end

  private

  def judgement_params
    params.require(:judgement).permit(:purchase_status)
  end
end
