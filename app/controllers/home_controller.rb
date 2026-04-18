class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @purchased_price = current_user.items.joins(:judgement)
    .where(judgements: { purchase_status: Judgement.purchase_statuses[:purchased] })
    .sum(:price)

    @skipped_price = current_user.items.joins(:judgement)
    .where(judgements: { purchase_status: Judgement.purchase_statuses[:skipped] })
    .sum(:price)

    @judged_price = @purchased_price + @skipped_price

    ## 0除算対策
    if @judged_price == 0
      @purchased_ratio = 0
      @skipped_ratio = 0
    else
      ## 判断済みアイテムの合計額に対する購入金額と見送り金額の比率
      @purchased_ratio = (@purchased_price.to_f / @judged_price * 100).round(1)
      @skipped_ratio = (@skipped_price.to_f / @judged_price * 100).round(1)
    end

    ## 判定待ちアイテムの一覧を取得
    ## enum purchase_status: { considering: 0, purchased: 1, skipped: 2 }
    @yet_to_judge = current_user.items
                                .includes(:reminder, :judgement)
                                .joins(:judgement, :reminder)
                                .where(judgements: { purchase_status: Judgement.purchase_statuses[:considering] })
                                .order("reminders.remind_at ASC")
  end
end
