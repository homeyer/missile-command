five = require 'johnny-five'

module.exports = (->
  class Servo
    constructor: (options) ->
      @reversed = options.reversed
      @servo = new five.Servo(options)
      @loaded = 0
      @maxLoad = 3

    load: ->
      return if @loaded == @maxLoad
      @loaded += 1
      newPosition = @add 60
      console.log "loading rubber band"
      @servo.move newPosition

    fire: ->
      return if @loaded == 0
      @loaded -= 1
      newPosition = @subtract 60
      console.log "firing rubber band"
      @servo.move newPosition

    clear: ->
      method = if @reversed then 'max' else 'min'
      console.log "calling #{method} on servo"
      @servo[method]()
      @loaded = 0

    add: (amount) ->
      if @reversed then @servo.last.degrees - amount else @servo.last.degrees + amount

    subtract: (amount) ->
      if @reversed then @servo.last.degrees + amount else @servo.last.degrees - amount
)()