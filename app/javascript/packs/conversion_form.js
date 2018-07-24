import TurbolinksAdapter from 'vue-turbolinks';
import Vue from 'vue/dist/vue.esm'

Vue.use(TurbolinksAdapter)


document.addEventListener("turbolinks:load", function() {
  const app = new Vue({
    el: '#new_conversion',
    data: {
      selected: ''
    },
    methods: {
      setYnabHiddenFields: function() {
        var account = this.$refs[this.selected]

        if (account) {
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
