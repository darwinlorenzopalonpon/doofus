import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  connect() {
    // Bind keyboard events
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    // Clean up event listeners
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  // Action to open the sidebar
  open() {
    this.sidebarTarget.classList.add("open")
    this.overlayTarget.classList.add("active")
    document.body.classList.add("sidebar-open")
  }

  // Action to close the sidebar
  close() {
    this.sidebarTarget.classList.remove("open")
    this.overlayTarget.classList.remove("active")
    document.body.classList.remove("sidebar-open")
  }

  // Action to toggle the sidebar
  toggle() {
    if (this.sidebarTarget.classList.contains("open")) {
      this.close()
    } else {
      this.open()
    }
  }

  // Action for clicking overlay to close
  closeOnOverlay(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }

  // Action for navigation links (close sidebar after small delay)
  navigateAndClose() {
    setTimeout(() => {
      this.close()
    }, 100)
  }

  // Handle keyboard events
  handleKeydown(event) {
    if (event.key === "Escape" && this.sidebarTarget.classList.contains("open")) {
      this.close()
    }
  }
}
