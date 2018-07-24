import 'bootstrap-datepicker'

document.addEventListener("turbolinks:load", function() {
  $('.datepicker').datepicker({
    format: "dd/mm/yyyy",
    weekStart: 1,
    autoclose: true,
    todayHighlight: true
  });
})
