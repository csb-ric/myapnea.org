@registrationUX = () ->
  $(".circle-progress").click ->
    circle = $(this)
    if circle.prev().hasClass "track-progress"
      circle.prevAll().andSelf().animate
        backgroundColor: "#78c679", 400, ->
          circle.addClass "viewed"
          circle.prev().addClass "viewed"
    if circle.next().hasClass "viewed"
      circle.nextAll().animate
        backgroundColor: "#d5ecd2", 400, ->
          circle.nextAll().removeClass "viewed"

  # Show privacy modal on registration page
  if $("#introPrivacyModal").length > 0
    $("#introPrivacyModal").modal "show"
