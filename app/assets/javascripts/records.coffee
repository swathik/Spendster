class Records
  constructor: ->
    @document_ready()

  document_ready: ->
    $(document).ready =>
      @category_multiple_rows()
      @emails_multiple_rows()
      @ajax_error()
      @ajax_success()
      @spend_period_ajax_error()
      @spend_period_ajax_success()
      @apply_tooltips()
      @apply_popovers()
      @toggleShowEditRecord()
    
  apply_tooltips: ->
    $('.tool_tip').tooltip(placement: 'right')
  
  apply_popovers: ->
    $('.popinfo').popover(placement: 'right')
    
  toggleShowEditRecord: ->
    edit = $('.edit_record_div')
    show = $('.show_record')
    toggle = $('#toggle_show_edit_record')
    $(toggle).live 'click', (event)->
      if $(edit).hasClass('hide')
        $(toggle).text('Show Budget List')
        $(edit).removeClass('hide')
        $(show).addClass('hide')
      else
        $(toggle).text('Edit Budget List')
        $(show).removeClass('hide')
        $(edit).addClass('hide')
      event.preventDefault()
  
  category_multiple_rows: =>
    index_value = $('#index')
    if $(index_value).length > 0
      @index = $(index_value).length + 2
    else
      @index = 0
    @handle_plus_option()
  
    $('img.plus_button').live 'click', (event) =>
      @handle_plus_option()
  
    $('img.minus_button').live 'click', (event) ->
      if ($('img.minus_button').size() == 2)
        $('div.category_limits').find('div.criteria input').val('')
        return
      else
        $(this).closest('.criteria').remove()
      event.preventDefault()
  
  emails_multiple_rows: =>
    email_index_value = $('#email_index')
    if $(email_index_value).length > 0
      @email_index = $(email_index_value).length + 1
    else
      @email_index = 0
    @handle_email_plus_option()
      
    $('img.email_plus_button').live 'click', (event) =>
      @handle_email_plus_option()

    $('img.email_minus_button').live 'click', (event) ->
      if ($('img.email_minus_button').size() == 2)
        $('div.user_emails').find('div.criteria input').val('')
        return
      else
        $(this).closest('.criteria').remove()
      event.preventDefault()
      
  handle_plus_option: =>
    if $('#template').length > 0
      html = $('#template').html().replace(/INDEX/g, @index)
      $('.category_limits').append(html)
      @index = @index + 1
    
  handle_email_plus_option: =>
    if $('#email_template').length > 0
      html = $('#email_template').html().replace(/INDEX/g, @email_index)
      $('.user_emails').append(html)
      @email_index = @email_index + 1
    
  ajax_error: ->
    $('form#new_record, form#edit_record').live 'ajax:error', (event, jqXHR) ->
      $('#record_error').html(jqXHR.responseText).removeClass('hide')
      
  ajax_success: ->
    $('form#new_record, form#edit_record').live 'ajax:success', (event, data, status, xhr) ->
      window.location = window.location.origin + "/records/#{data.id}"

  spend_period_ajax_error: ->
    $('form#new_record_spend_period').live 'ajax:error', (event, jqXHR) ->
      $('#period_error').html(jqXHR.responseText).removeClass('hide')
      
  spend_period_ajax_success: ->
    $('form#new_record_spend_period').live 'ajax:success', (event, data, status, xhr) ->
      window.location = window.location
    
records = new Records
      