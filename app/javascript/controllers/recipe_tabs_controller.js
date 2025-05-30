import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "content"]

  connect() {
    // Initialize first tab as active
    this.showTab(0)
  }

  switchTab(event) {
    event.preventDefault()
    const tabIndex = parseInt(event.currentTarget.dataset.index)
    this.showTab(tabIndex)
  }

  showTab(index) {
    // Remove active class from all tabs and content
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle("active", i === index)
    })

    this.contentTargets.forEach((content, i) => {
      content.classList.toggle("show", i === index)
      content.classList.toggle("active", i === index)
    })
  }
}
