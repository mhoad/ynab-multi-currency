import 'bootstrap-datepicker'

document.addEventListener("turbolinks:load", function() {
  function setYnabHiddenFields() {
    var budgetId = $("#conversion_ynab_account_id").find(":selected").data("budget-id");
    var budgetName = $("#conversion_ynab_account_id").find(":selected").data("budget-name");
    var accountName = $("#conversion_ynab_account_id").find(":selected").data("account-name");
    var toCurrency = $("#conversion_ynab_account_id").find(":selected").data("to-currency");

    $("#conversion_ynab_budget_id").val(budgetId);
    $("#conversion_cached_ynab_account_name").val(budgetName);
    $("#conversion_cached_ynab_budget_name").val(accountName);
    $("#conversion_to_currency").val(toCurrency);
  }

  setYnabHiddenFields();

  $("#conversion_ynab_account_id").change(function() {
    setYnabHiddenFields();
  });

  $('.datepicker').datepicker({
    format: "dd/mm/yyyy",
    weekStart: 1,
    autoclose: true,
    todayHighlight: true
  });
})
