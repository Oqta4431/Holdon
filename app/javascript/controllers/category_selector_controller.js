import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "field", "label"]

  openModal() {
    this.dialogTarget.showModal()

    // daisyUI の dialog は非表示のため Turbo Frame が自動ロードされない。
    // モーダルを開くたびに reload() を呼ぶことで最新のカテゴリー一覧を取得する。
    const frame = this.dialogTarget.querySelector("turbo-frame")
    if (frame) frame.reload()
  }

  selectCategory(event) {
    event.preventDefault()
    const { categoryId, categoryName } = event.currentTarget.dataset

    // hidden field を更新してフォーム送信時に category_id が渡るようにする
    this.fieldTarget.value = categoryId

    // 表示テキストを選択したカテゴリー名に更新する
    this.labelTarget.textContent = categoryName || "なし"
    this.labelTarget.classList.toggle("text-base-content/40", !categoryId)

    this.dialogTarget.close()
  }
}
