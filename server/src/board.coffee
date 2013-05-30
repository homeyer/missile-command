five = require "johnny-five"
EventEmitter = require("events").EventEmitter
_ = require 'lodash'

module.exports = (->

  class MissileBoard extends EventEmitter

    constructor: ->
      @board = new five.Board()

      @board.on "ready", =>
        @leds = (new five.Led(i) for i in [12..5])
        this.emit('ready')
       
    strobeLights: (ms = 10000) ->
       
        # Create an Led on pin 13 and strobe it on/off
        # optionally set the speed; defaults to 100ms
        console.log 'Strobing LED'
        @_lightsOut()
        _.each @leds, (led) ->
          led.strobe()

          @board.wait ms, ->

            console.log 'Stopping LED'
            led.stop().off()

    runwayLights: ->
      console.log 'starting runway lights'
      @_lightsOut()
      delay = 0
      _.times 5, =>
        delay += 300 if delay > 0
        _.each(
          _.map @leds, (led) =>
            led: led
            delay: delay += 50

          (ledWithDelay) =>
            @board.wait ledWithDelay.delay, =>
              @._onOff ledWithDelay.led, 100
        )

    meterLights: (count = 4) ->
      @_lightMeter count, 'on'

    startMotor: (ms = 5000) ->
      motor = new five.Motor(
        pin: 3
      )

      motor.on "start", (err, timestamp) ->
          console.log( "motor started", timestamp )

          # Demonstrate motor stop in 2 seconds
          @board.wait ms, ->
            console.log "stopping motor"
            motor.stop()

      motor.start()

    stopMotor: ->
      motor = new five.Motor(
        pin: 3
      )

      console.log 'stopping motor'
      motor.stop()

    _onOff: (led, duration) ->
      led.on()
      @board.wait duration, -> led.off()

    _lightMeter: (value, methodName) ->
      @_lightsOut()
      _.invoke _.first(@leds, value), methodName

      # @board.wait 10000, ->
      #   console.log 'turning off light meter'

    _lightsOut: ->
      _.invoke @leds, 'off'

  new MissileBoard()
)()
