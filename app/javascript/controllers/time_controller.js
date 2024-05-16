import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "hours", "minutes" ]
  static values = { timestamp: Number }

  connect() {
    setInterval(() => this.updateTime(), 1000);
  }

  updateTime() {
    this.timestampValue++;
    const date = new Date(this.timestampValue * 1000);
    this.hoursTarget.textContent = date.getHours().toString().padStart(2, '0');
    this.minutesTarget.textContent = date.getMinutes().toString().padStart(2, '0');
  }
}
