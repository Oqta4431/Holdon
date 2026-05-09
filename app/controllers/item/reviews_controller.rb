class Item::ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item

  def new
    if @item.review
      redirect_to root_path, error: t(".error")
    else
      @review = Review.new
    end
  end

  def create
    if @item.review
      return redirect_to root_path, error: t(".error")
    end

    @review = @item.build_review(review_params)
    if @review.save
      redirect_to root_path, success: t(".success")
    else
      flash.now[:alert] = t(".alert")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_item
    @item = current_user.items.find(params[:item_id])
  end

  def review_params
    params.require(:review).permit(:satisfaction_score, :comment)
  end
end
