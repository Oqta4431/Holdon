import { Controller } from "@hotwired/stimulus"

// テキストの折りたたみ・展開を管理するコントローラー。
// 接続時にテキストが実際に溢れているかを確認し、溢れていない場合はトグルボタンを非表示にする。
export default class extends Controller {
  static targets = ["text", "toggle"]

  connect() {
    if (this.textTarget.scrollHeight <= this.textTarget.clientHeight) {
      this.toggleTarget.classList.add("hidden")
    }
  }

  expand() {
    // line-clamp-4 クラスの有無でトグルし、ボタンラベルを切り替える
    const isCollapsed = this.textTarget.classList.toggle("line-clamp-4")
    this.toggleTarget.textContent = isCollapsed ? "続きを表示" : "閉じる"
  }
}
