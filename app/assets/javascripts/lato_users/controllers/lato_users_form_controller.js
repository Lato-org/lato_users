import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "password",
    "passwordConfirmation",
    "generatedPassword"
  ]
  
  connect() {
   
  }

  generatePassword(event) {
    event.preventDefault()
    const length = 12
    const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    let retVal = ""
    for (let i = 0, n = charset.length; i < length; ++i) {
        retVal += charset.charAt(Math.floor(Math.random() * n))
    }
    
    this.passwordTarget.value = retVal
    this.passwordConfirmationTarget.value = retVal
    this.generatedPasswordTarget.value = retVal
  }
}