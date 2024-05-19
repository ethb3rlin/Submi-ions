import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  reset() {
    this.element.reset()
  }

  submitIfCtrlEnter(event) {
    if (event.key === "Enter" && (event.ctrlKey || event.metaKey)) {
      event.preventDefault()
      this.element.requestSubmit()
      this.reset()
    }
  }
}
