import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="voting"
export default class extends Controller {
  static targets = ["slider", "field"]
  static values = { path: String }

  updateNumber() {
    // Rendering the number with one decimal
    let value = parseFloat(this.sliderTarget.value).toFixed(1);
    this.fieldTarget.innerHTML = value;
  }

  submitValue() {
    // If we're on /judgements/<id>/edit URL, reset `completed` to false
    // Otherwise keep the value as it is
    var vote_data = { mark: this.sliderTarget.value } ;
    if (window.location.pathname.match(/\/judgements\/\d+\/edit/)) {
      vote_data.completed = false;
    }

    fetch(this.pathValue, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      body: JSON.stringify({ vote: vote_data })
    })
  }
}
