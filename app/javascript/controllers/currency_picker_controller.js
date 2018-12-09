import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "accounts", "toCurrency" ]

  connect() {
    this.setToCurrency
  }

  setToCurrency() {
    var accounts = this.accountsTarget
    var account = accounts.options[accounts.selectedIndex]

    if (account.value) {
      this.toCurrencyTarget.value = account.dataset.toCurrency
    } else {
      this.toCurrencyTarget.value = ""
    }
  }
}
