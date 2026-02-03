class ReasonsController < ApplicationController
  before_action :authenticate_user!

  def update
    @item = current_user.items.find(params[:item_id])
    @reason = @item.reason || @item.build_reason

    if @reason.update(reason_params)
      redirect_to item_path(@item), success: "理由を保存しました"
    else
      flash.now[:error] = "理由を保存できませんでした"
      render "items/show", status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    flash[:error] = "保存に失敗しました"
    redirect_to items_path
  end

  private

  def reason_params
    params.require(:reason).permit(:purchase_reason, :skip_reason)
  end
end
