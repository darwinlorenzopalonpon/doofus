import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submitButton", "loadingSpinner", "content"]

  submitForm(event) {
    this.showLoadingState(true)
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
