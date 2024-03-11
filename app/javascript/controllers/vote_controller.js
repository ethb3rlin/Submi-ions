import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="voting"
export default class extends Controller {
  static targets = [ "slider", "field" ]
  static values = { path: String }

  connect() {
    console.log(this.pathValue)
  }

  timer = undefined;

  handleUpdate() {
    this.fieldTarget.innerHTML = this.sliderTarget.value;
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      fetch(this.pathValue, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        },
        body: JSON.stringify({ vote: { mark: this.sliderTarget.value } })
      })
    }, 500);
  }
}