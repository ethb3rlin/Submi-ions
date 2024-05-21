import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slider", "field"]
  static values = { path: String }

  updateNumber() {
    let value = parseFloat(this.sliderTarget.value).toFixed(1);
    this.fieldTarget.innerHTML = value;
  }

  submitValue() {
    var vote_data = { score: this.sliderTarget.value } ;
    fetch(this.pathValue, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify({ judgement: vote_data })
    })
  }
}
