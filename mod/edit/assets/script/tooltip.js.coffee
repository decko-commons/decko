$ ->
  tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
  tooltipList = $.map tooltipTriggerList, (tooltipTriggerEl) ->
    new bootstrap.Tooltip tooltipTriggerEl
