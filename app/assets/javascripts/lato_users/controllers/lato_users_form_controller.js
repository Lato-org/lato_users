import { Controller } from "@hotwired/stimulus"

const CHARACTER_CLASSES = [
  "abcdefghijklmnopqrstuvwxyz",
  "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
  "0123456789",
  "!@#$%^&*"
]

export default class extends Controller {
  static targets = [
    "password",
    "passwordConfirmation",
    "generatedPassword",
    "status"
  ]

  static values = {
    length: { type: Number, default: 16 },
    generatedMessage: String,
    confirmMessage: String
  }

  generatePassword(event) {
    event.preventDefault()
    const password = this.buildPassword()

    this.passwordTarget.value = password
    this.passwordConfirmationTarget.value = password
    this.generatedPasswordTarget.value = password
    if (this.hasStatusTarget) this.statusTarget.textContent = this.generatedMessageValue
  }

  // The form opts out of Turbo (the response must render in place, see force_update_password), so it asks for confirmation itself.
  confirmSubmit(event) {
    if (!window.confirm(this.confirmMessageValue)) event.preventDefault()
  }

  // One character per class (password policies), the rest from the full charset, then shuffled.
  buildPassword() {
    const charset = CHARACTER_CLASSES.join("")
    const chars = CHARACTER_CLASSES.map((characters) => this.pick(characters))
    while (chars.length < this.lengthValue) chars.push(this.pick(charset))

    for (let i = chars.length - 1; i > 0; i--) {
      const j = this.randomInt(i + 1)
      ;[chars[i], chars[j]] = [chars[j], chars[i]]
    }
    return chars.join("")
  }

  pick(characters) {
    return characters.charAt(this.randomInt(characters.length))
  }

  // Uniform integer in [0, max) from a CSPRNG, rejecting the biased tail of the 32-bit range.
  randomInt(max) {
    const limit = Math.floor(0x100000000 / max) * max
    const buffer = new Uint32Array(1)
    do {
      crypto.getRandomValues(buffer)
    } while (buffer[0] >= limit)
    return buffer[0] % max
  }
}
