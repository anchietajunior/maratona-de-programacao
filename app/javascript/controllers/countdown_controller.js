import { Controller } from "@hotwired/stimulus"

// Counts the contest down from the seconds the server rendered. Counting locally instead
// of comparing clocks keeps the number right even if the lab machine's clock drifts.
export default class extends Controller {
  static values = { seconds: Number }

  connect() {
    this.remaining = this.secondsValue
    this.#render()
    this.timer = setInterval(() => this.#tick(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  #tick() {
    this.remaining = Math.max(0, this.remaining - 1)
    this.#render()

    if (this.remaining === 0) clearInterval(this.timer)
  }

  #render() {
    const hours = Math.floor(this.remaining / 3600)
    const minutes = Math.floor((this.remaining % 3600) / 60)
    const seconds = this.remaining % 60

    this.element.textContent = [hours, minutes, seconds]
      .map((unit) => String(unit).padStart(2, "0"))
      .join(":")
  }
}
