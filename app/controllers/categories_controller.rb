class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %i[destroy]

  def modal
    # current_user のカテゴリーのみ取得（他ユーザーのカテゴリーは参照不可）
    @categories = current_user.categories.order(:name)
    @return_to = params[:return_to]
  end

  def index
    @categories = current_user.categories.order(:name)
    @return_to = params[:return_to]
  end

  def new
    @category = Category.new
    # カテゴリー作成後の戻り先URLを保持する（items/new または items/:id/edit）
    @return_to = params[:return_to]
  end

  def create
    # @category = Category.new では user_id が空になるため
    # buildを採用
    @category = current_user.categories.build(category_params)

    if @category.save
      redirect_to build_return_url(@category), success: t("categories.create.success")
    else
      @return_to = params[:return_to]
      flash.now[:error] = t("categories.create.error")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy!
    redirect_to categories_path, success: t("categories.destroy.success")
  end

  private

  def set_category
    # current_user スコープで検索することで他ユーザーのカテゴリーIDを指定されても 404 になる
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end

  def build_return_url(category)
    # return_to が安全なURLの場合、selected_category_id を付与して戻り先を構築する
    return items_path unless valid_return_to?(params[:return_to])

    uri = URI.parse(params[:return_to])
    # 既存のクエリパラメーターを維持しつつ selected_category_id を追加
    query_params = URI.decode_www_form(uri.query.to_s).to_h
    query_params["selected_category_id"] = category.id.to_s
    uri.query = URI.encode_www_form(query_params)
    uri.to_s
  end

  def valid_return_to?(url)
    return false if url.blank?

    uri = URI.parse(url)
    # オープンリダイレクト対策：相対パスまたは同一ホストのURLのみ許可
    uri.host.nil? || uri.host == request.host
  rescue URI::InvalidURIError
    false
  end
end
