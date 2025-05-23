import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submitButton", "loadingSpinner", "content"]

  connect() {
    console.log("Meal controller connected!")
  }

  submitForm(event) {
    console.log("Form submission intercepted")

    // Show loading state
    this.showLoadingState(true)

    // Let the form submit naturally
    // The controller doesn't prevent the default behavior
  }

  showLoadingState(isLoading) {
    if (isLoading) {
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.disabled = true
        this.submitButtonTarget.classList.add("loading")
      }

      if (this.hasLoadingSpinnerTarget) {
        this.loadingSpinnerTarget.style.display = "block"
      }

      if (this.hasContentTarget) {
        this.contentTarget.classList.add("loading")
      }
    } else {
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.disabled = false
        this.submitButtonTarget.classList.remove("loading")
      }

      if (this.hasLoadingSpinnerTarget) {
        this.loadingSpinnerTarget.style.display = "none"
      }

      if (this.hasContentTarget) {
        this.contentTarget.classList.remove("loading")
      }
    }
  }
}
