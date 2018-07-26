import TurbolinksAdapter from 'vue-turbolinks';
import Vue from 'vue/dist/vue.esm'

Vue.use(TurbolinksAdapter)


document.addEventListener("turbolinks:load", function() {
  const app = new Vue({
    el: '.conversion-vue',
    methods: {
      setYnabHiddenFields: function() {
        var accounts = document.getElementById("conversion_ynab_account_id")
        var account = accounts.options[accounts.selectedIndex]

        if (account.value) {
          document.getElementById("conversion_to_currency").value = account.dataset.toCurrency
          document.getElementById("conversion_ynab_budget_id").value = account.dataset.budgetId
          document.getElementById("conversion_cached_ynab_budget_name").value = account.dataset.budgetName
          document.getElementById("conversion_cached_ynab_account_name").value = account.dataset.accountName
        } else {
          document.getElementById("conversion_to_currency").value = ""
          document.getElementById("conversion_ynab_budget_id").value = ""
          document.getElementById("conversion_cached_ynab_budget_name").value = ""
          document.getElementById("conversion_cached_ynab_account_name").value = ""
        }
      }
    },
    mounted() {
      this.setYnabHiddenFields()
    }
  })
})
