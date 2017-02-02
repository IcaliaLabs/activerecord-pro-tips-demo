App.log = App.cable.subscriptions.create 'LogChannel',
  connected: ->
    # Called when the subscription is ready for use on the server
    console.log 'connected'
    @displayConnected()

  disconnected: ->
    # Called when the subscription has been terminated by the server
    console.log 'disconnected'
    @displayDisconnected()

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    console.log data

    @displayConnected()

    if data.type == 'sql'
      message = @createSQLMessage(data) if data.name != 'SCHEMA'
    else
      message = @createActionControllerMessage(data)

    loggerOutput = jQuery('.rails-logger .logger-output')
    jQuery(message).appendTo(loggerOutput) if message?
    jQuery(loggerOutput).scrollTop(loggerOutput.prop('scrollHeight'))

  createSQLMessage: (data) ->
    console.log 'createSQLMessage'
    name = "<span class=\"name\">#{data.name}</span>"
    duration = "<span class=\"duration\">#{data.duration}</span>"
    sql = "<span class=\"sql\">#{data.sql}</span>"
    "<li class=\"query\">#{name}#{duration}#{sql}</li>"

  createActionControllerMessage: (data) ->
    console.log 'createActionControllerMessage'
    "<li class=\"process-action\">#{data.message}</li>"

  displayConnected: ->
    jQuery('body').addClass 'log-channel-connected'
    jQuery('body').removeClass 'log-channel-disconnected'

  displayDisconnected: ->
    jQuery('body').addClass 'log-channel-disconnected'
    jQuery('body').removeClass 'log-channel-connected'

# Scroll down the logger output anytime turbolinks finishes loading a visit:
jQuery(document).on 'turbolinks:load', ->
  loggerOutput = jQuery('.rails-logger .logger-output')
  jQuery(loggerOutput).scrollTop(loggerOutput.prop('scrollHeight'))
