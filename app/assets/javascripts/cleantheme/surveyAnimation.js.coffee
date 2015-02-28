@surveyAnimationReady = () ->

  # Initiate flow when survey is present
  $(document).ready ->
    if $("[data-object~='survey-introduction']").length > 0
      multiple_radios = $("[data-object~='radio-input-multiple']")
      multiple_radios.each (index) ->
        $(multiple_radios[index]).children($("[data-object~='radio-input-multiple-container']")).first().addClass "current"
    return

  # Navigation for survey indicators
  $("[data-object~='survey-indicator']").click (e) ->
    target = 'question-container-' + $(this).data('target')
    assignQuestionDirect($("[data-object~='"+target+"']"))

  # Scroll to active question
  @nextQuestionScroll = (element2) ->
    # Check for multiple questions, and position the first question in the center
    if element2.find('.current').length > 0
      currentHeight = element2.find('.current').offset().top
      elementOffsetHeight = element2.find('.current').outerHeight() / 2
    else
      currentHeight = element2.offset().top
      elementOffsetHeight = element2.outerHeight() / 2
    offsetHeight = $(window).outerHeight() / 2
    # Check for large questions on small screens
    if elementOffsetHeight > offsetHeight
      newHeight = currentHeight - 91
    else
      newHeight = currentHeight - offsetHeight + elementOffsetHeight
    $("body").animate
      scrollTop: newHeight, 400, "swing"
    , ->
      changeFocus(element2)
      return

  @changeFocus = (question) ->
    $("input").blur()
    $(question).find("input:not([type=hidden])").first().focus()

  @assignQuestionDirect = (element) ->
    $(".survey-container.active").removeClass "active"
    $(element).addClass "active"
    nextQuestionScroll($(".survey-container.active"))

  # Progress to next or previous question
  @assignQuestion = (next, prev) ->
    activeQuestion = $(".survey-container.active")
    if (next and activeQuestion.next().length) or (prev and activeQuestion.prev().length)
      activeQuestion.removeClass "active"
      if next
        activeQuestion.next().addClass "active"
      else if prev
        activeQuestion.prev().addClass "active"
      nextQuestionScroll($(".survey-container.active"))

  # Progress to next part in multiple-part question
  @assignMultipleQuestion = (next, prev) ->
    activeQuestion = $(".survey-container.active .multiple-question-container.current")
    if (next and activeQuestion.nextAll().length) or (prev and activeQuestion.prevAll().length)
      activeQuestion.removeClass "current"
      if next
        activeQuestion.nextAll(".multiple-question-container").first().addClass "current"
      else if prev
        activeQuestion.prevAll(".multiple-question-container").first().addClass "current"
      newActiveQuestion = $(".survey-container.active .multiple-question-container.current")
      nextQuestionScroll(newActiveQuestion)
    else if (next and !activeQuestion.nextAll().length)
      assignQuestion(true, false)
    else if (prev and !activeQuestion.prevAll().length)
      assignQuestion(false, true)

  # Submit a survey answer
  @submitAnswer = (inputElement) ->
    questionForm = inputElement.closest("form")
    $.post(questionForm.attr("action"), questionForm.serialize(), (data) ->
      indicator = $(questionForm).data('object').slice(-1)
      indicatorSelector = $("[data-object~='survey-indicator'][data-target~='"+indicator+"']")
      if data['completed']
        indicatorSelector.removeClass 'incomplete'
        indicatorSelector.addClass 'complete'
        indicatorSelector.html "&#10003;"
      else
        indicatorSelector.removeClass 'complete'
        indicatorSelector.addClass 'incomplete'
        indicatorSelector.html Number(indicator) + 1
    , 'json')

  @handleChangedValue = (inputElement) ->
    submitAnswer(inputElement)

  @revealNextInput = (targetInput) ->
    $("[data-receiver~="+targetInput+"]").find("input").first().focus()



  #################
  # SURVEY CLICKS #
  #################

  # Handle 'prefer not to answer checkbox'
  $('.preferred-not-to-answer').click (e) ->
    $(this).find('input:checkbox').prop "checked", !$(this).find('input:checkbox').prop("checked")
    return

  # Respond to click events on conditional events - note that this only works on checkbox inputs
  $("[data-object~='reveal-next-input']").click (e) ->
    if this.checked then revealNextInput($(this).data('target'))

  $('input:radio').click (event) ->
    event.stopPropagation()
    unless $(this).data('secondary')
      $(this).prop "checked", true
      if $(this).data('object') == 'reveal-next-input'
        revealNextInput($(this).data('target'))
      else if $(this).closest('.multiple-question-container').length
        if $(this).closest(".multiple-question-container").hasClass "current"
          assignMultipleQuestion(true,false)
      else
        assignQuestion(true,false)

  # Respond to user clicking different questions
  $('.survey-container').click (event) ->
    event.stopPropagation()
    # For click events on 'Next Question' button, just assign next question
    if $(event.target).hasClass "next-question"
      assignQuestion(true, false)
    else if !$(this).hasClass "active"
      assignQuestionDirect($(this))

  #####################
  # SURVEY KEYSTROKES #
  #####################

  $("body").keydown (e) ->
    if $('.survey-container').length
      # Prevent default up and down and enter on keydown
      if e.keyCode is 38 or e.keyCode is 40 or e.keyCode is 13
        e.preventDefault()
      # Specifically targeting custom date input
      if $(".survey-container.active").find(".survey-custom-date").is(":focus")
        # Allow regular command and left/right keys
        if e.metaKey or e.keyCode is 37 or e.keyCode is 39
          return
        # Ensure proper blurring of date input
        else if e.keyCode is 13
          $(".survey-container.active").find(".survey-custom-date").blur()
          return
        # Autocomplete date when tab or / is pressed
        else if e.keyCode is 9 or e.keyCode is 191
          e.preventDefault()
          autocompleteDate()
          return
        # Allow deleting, with dynamic string completion
        else if e.keyCode is 46 or e.keyCode is 8
          writeDate(e.keyCode)
          return
        else if (/^[a-zA-Z]*$/.test(+String.fromCharCode(e.keyCode)))
          # prevent letter from returning
          e.preventDefault()
        else if (/^[0-9]{1,10}$/.test(+String.fromCharCode(e.keyCode)))
          # allow number to be written
          # e.preventDefault()
          writeDate(e.keyCode)

  $("body").keyup (e) ->
    if $('.survey-container').length
      # Handle navigating using the up/down arrow keys
      if e.keyCode is 38
        e.preventDefault()
        if $(".survey-container.active").hasClass "multiple-question-parts" then assignMultipleQuestion(false, true) else assignQuestion(false, true)
      else if e.keyCode is 40
        e.preventDefault()
        if $(".survey-container.active").hasClass "multiple-question-parts" then assignMultipleQuestion(true, false) else assignQuestion(true, false)
      # Progress to next question for enter
      else if e.keyCode is 13
        assignQuestion(true, false)
        return
      # Handle hidden inputs first to prevent extra entering
      if $("input:focus").is(":text")
        return
      # Handle 'prefer not to answer checkbox'
      else if $(this).find('.preferred-not-to-answer').length
        return
      # Handle radio_input_multiple
      else if $(".survey-container.active").hasClass "multiple-question-parts"
        inputs = $(".survey-container.active .multiple-question-container.current").find("input:radio")
        inputs.each (index) ->
          if e.keyCode is $(inputs[index]).data("hotkey").toString().charCodeAt(0)
            $(inputs[index]).prop "checked", true
            handleChangedValue($(inputs[index]))
            assignMultipleQuestion(true, false)
      # Respond to actual inputs
      else
        # Progress to next question if applicable
        if $(".survey-container.active").data('progress')
          inputs = $(".survey-container.active").find("input:radio")
          inputs.each (index) ->
            if e.keyCode is $(this).data("hotkey").toString().charCodeAt(0)
              $(inputs[index]).prop "checked", true
              handleChangedValue($(inputs[index]))
              if $(inputs[index]).data('object') == "reveal-next-input" then revealNextInput($(inputs[index]).data('target')) else assignQuestion(true, false)
        # Otherwise, check answer
        else
          inputs = $(".survey-container.active").find("input:checkbox")
          inputs.each (index) ->
            if e.keyCode is $(inputs[index]).data("hotkey").toString().charCodeAt(0)
              if !($(inputs[index]).prop "checked") and ($(inputs[index]).data('object') == "reveal-next-input")
                revealNextInput($(inputs[index]).data('target'))
              $(inputs[index]).prop "checked", !$(inputs[index]).prop("checked")
              handleChangedValue($(inputs[index]))


  # Attach change event handler to everything but radio button inputs. Radio button inputs are changed by JS, so each time
  # the :checked property is changed, handleChangedValue has to be called.
  $("input").change (event) ->
    if $("input").parents(".survey-container").length
      handleChangedValue($(event.target))

  #####################
  # SURVEY SUBMISSION #
  #####################

  $("[data-object~='survey-submit-btn']").click (e) ->
    e.stopPropagation()
    $.post($(this).data("path"),
      {answer_session_id: $(this).data("answer-session-id")}, (data) ->
        console.log data
    )
    if checkCompletion()
      $(this).addClass 'hidden'
      $("[data-object~='survey-submit-congratulations-container']").removeClass 'hidden'
    else
      $("[data-object~='survey-indicator'].incomplete").addClass 'error'
      target = 'question-container-' + $("[data-object~='survey-indicator'].incomplete").first().data('target')
      assignQuestionDirect($("[data-object~='"+target+"']"))

    return

  @checkCompletion = () ->
    numberSelectors = $("[data-object~='survey-indicator']").length
    numberCompletedSelectors = $("[data-object~='survey-indicator'].complete").length
    if numberSelectors == numberCompletedSelectors
      return true
    else
      return false


  # Custom date input - New version
  @writeDate = (keyCode) ->
    date_index = $(".survey-custom-date").val().length || 0
    if keyCode is 8
      return
    else if date_index == 2 or date_index == 5 #or date_index == 1 or date_index == 4
      $(".survey-custom-date").val($(".survey-custom-date").val()+'/')
    else
      return

  @autocompleteDate = () ->
    date_index = $(".survey-custom-date").val().length || 0
    dateVal = $(".survey-custom-date").val()
    if date_index == 1
      $(".survey-custom-date").val('0'+dateVal+'/')
    else if date_index == 2
      $(".survey-custom-date").val(dateVal+'/')
    else if date_index == 4
      $(".survey-custom-date").val(dateVal[0..2]+'0'+dateVal[3]+'/')
    else if date_index == 5
      $(".survey-custom-date").val(dateVal+'/')
    else
      return
