import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image", "spinner", "title", "metadata", "container", "error"]

  connect() {
    console.log("Meme controller connected!")
    
    // Fetch a fresh meme on page load with a slight delay for transitions
    setTimeout(() => this.fetchMeme(), 50)
  }

  fetchMeme() {
    console.log("Fetching meme...")
    this.showLoadingState(true)
    this.clearError()
    
    // Clear existing content during loading
    if (this.hasTitleTarget) {
      this.titleTarget.textContent = ""
      this.titleTarget.style.opacity = '0'
    }
    
    if (this.hasMetadataTarget) {
      this.metadataTarget.innerHTML = ""
      this.metadataTarget.style.opacity = '0'
    }
    
    fetch('https://meme-api.com/gimme')
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok')
        }
        return response.json()
      })
      .then(data => {
        console.log("Meme received:", data)
        this.loadMeme(data)
      })
      .catch(error => {
        console.error('Error fetching meme:', error)
        this.showError("Failed to load meme. Try again?")
        this.showLoadingState(false)
      })
  }

  loadMeme(meme) {
    if (this.hasImageTarget && this.hasSpinnerTarget) {
      const newImage = new Image()
      
      // Store meme data for when image loads
      this.pendingMeme = meme
      
      // Set up event handlers
      newImage.onload = () => {
        console.log("Image loaded successfully")
        this.spinnerTarget.style.display = 'none'
        
        // Replace the old image
        const oldImage = this.imageTarget
        newImage.className = 'meme-image'
        newImage.dataset.memeTarget = 'image'
        newImage.alt = meme.title
        
        // Replace image first
        oldImage.style.opacity = '0'
        setTimeout(() => {
          oldImage.parentNode.replaceChild(newImage, oldImage)
          newImage.style.opacity = '1'
          
          // Now update title and metadata
          this.updateTextContent(meme)
          
          // Final loading state update
          this.showLoadingState(false)
        }, 200)
      }
      
      newImage.onerror = () => {
        console.error("Image failed to load:", meme.url)
        this.showError("Failed to load image. Try another meme.")
        this.spinnerTarget.style.display = 'none'
        this.showLoadingState(false)
      }
      
      // Set the source last to prevent race conditions
      newImage.src = meme.url
    }
  }
  
  updateTextContent(meme) {
    // Update title
    if (this.hasTitleTarget) {
      this.titleTarget.textContent = meme.title
      this.titleTarget.style.opacity = '1'
    }
    
    // Update metadata
    if (this.hasMetadataTarget) {
      this.metadataTarget.innerHTML = `From r/${meme.subreddit} • Posted by u/${meme.author}`
      this.metadataTarget.style.opacity = '1'
    }
  }

  showLoadingState(isLoading) {
    if (!this.hasContainerTarget) return;
    
    if (isLoading) {
      if (this.hasSpinnerTarget) {
        this.spinnerTarget.style.display = 'block'
      }
      
      if (this.hasImageTarget) {
        this.imageTarget.style.opacity = '0.3'
      }
      
      this.containerTarget.classList.add('loading')
    } else {
      this.containerTarget.classList.remove('loading')
    }
  }
  
  showError(message) {
    // Check if we have an error target, otherwise create one
    if (!this.hasErrorTarget && this.hasContainerTarget) {
      const errorDiv = document.createElement('div')
      errorDiv.className = 'error-message'
      errorDiv.dataset.memeTarget = 'error'
      this.containerTarget.appendChild(errorDiv)
    }
    
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.style.display = 'block'
    } else {
      console.error('Error message:', message)
    }
  }
  
  clearError() {
    if (this.hasErrorTarget) {
      this.errorTarget.style.display = 'none'
    }
  }
} 