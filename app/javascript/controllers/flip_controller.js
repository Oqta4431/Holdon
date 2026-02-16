import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["front", "back"]

  toggle() {
    this.frontTarget.classList.toggle("hidden")
    this.backTarget.classList.toggle("hidden")
  }
}
