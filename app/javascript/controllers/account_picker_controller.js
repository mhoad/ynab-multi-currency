import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "accounts", "budgetId", "budgetName", "accountName" ]

  connect() {
    this.setHiddenFields
  }

  setHiddenFields() {
    var accounts = this.accountsTarget
    var account = accounts.options[accounts.selectedIndex]

    if (account.value) {
      this.budgetIdTarget.value = account.dataset.budgetId
      this.budgetNameTarget.value = account.dataset.budgetName
      this.accountNameTarget.value = account.dataset.accountName
    } else {
      this.ynabBudgetIdTarget.value = ""
      this.budgetNameTarget.value = ""
      this.accountNameTarget.value = ""
    }
  }
}
