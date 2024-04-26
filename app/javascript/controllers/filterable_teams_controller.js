import { Controller } from "@hotwired/stimulus"

import List from "list.js"

// Connects to data-controller="filterable-teams"
export default class extends Controller {
  connect() {
    this.list = new List(this.element, {
      valueNames: [ 'name', 'agenda' ]
    })
  }

  filter(event) {
    this.list.search(event.target.value)
  }
}
