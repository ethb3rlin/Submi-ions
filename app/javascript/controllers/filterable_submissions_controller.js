import { Controller } from "@hotwired/stimulus"

import List from "list.js"

// Connects to data-controller="filterable-submissions"
export default class extends Controller {
  connect() {
    this.list = new List(this.element, {
      valueNames: [ 'submission-title', 'description', 'url' ]
    });
  }

  filter(event) {
    this.list.search(event.target.value)
  }
}
