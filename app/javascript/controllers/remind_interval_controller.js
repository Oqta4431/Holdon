import { Controller } from "@hotwired/stimulus"

  // リマインド期間ピッカー（数値セレクト × 単位セレクト）の入力を
  // 秒単位に変換して hidden フィールドにセットし、サーバーへ送信する
  export default class extends Controller {
    static targets = ["value", "unit", "seconds"]

    // 単位ごとの秒数係数
    // 分=60、時間=3600、日=86400
    UNIT_SECONDS = {
      minutes: 60,
      hours: 3_600,
      days: 86_400,
    }

    // 数値または単位が変更されたときに呼び出す
    calculate() {
      const value = parseInt(this.valueTarget.value, 10)
      const unit = this.unitTarget.value
      const multiplier = this.UNIT_SECONDS[unit] ?? 1

      // hidden フィールドに秒換算後の値をセット
      this.secondsTarget.value = value * multiplier
    }
  }