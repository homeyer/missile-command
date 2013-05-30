five = require "johnny-five"
EventEmitter = require("events").EventEmitter
_ = require 'lodash'
Servo = require './servo'

module.exports = (->

  class MissileBoard extends EventEmitter
    ledPins: [12, 11, 9, 8, 7, 6]
    reversedServoPin: 5

    constructor: ->
      @board = new five.Board()

      @board.on "ready", =>
        @leds = (new five.Led(i) for i in @ledPins)

        @servos = (new Servo(
          reversed: (i == @reversedServoPin)
          pin: i
          range: [ 0, 180 ] # Default: 0-180
          type: "standard" # Default: "standard". Use "continuous" for continuous rotation servos
          startAt: ((i == @reversedServoPin && 1) * 180) # if you would like the servo to immediately move to a degree
          center: false # overrides startAt if true and moves the servo to the center of the range
        ) for i in [5, 3])

        @servoLeds = [_.first(@leds, 3), _.last(@leds, 3)]

        @tilter = new five.Servo(
          pin: 10
          range: [ 0, 180 ] # Default: 0-180
          type: "standard" # Default: "standard". Use "continuous" for continuous rotation servos
          startAt: 5 # if you would like the servo to immediately move to a degree
          center: false # overrides startAt if true and moves the servo to the center of the range
        )

        # @buzzer = new five.Piezo(10)

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

    load: (deviceNumber) ->
      servo = @servos[deviceNumber]
      led = @servoLeds[deviceNumber][servo.loaded]
      led?.on()
      servo.load()

    fire: (deviceNumber) ->
      servo = @servos[deviceNumber]
      # @buzzer.tone( 20, 200 )
      servo.fire()
      led = @servoLeds[deviceNumber][servo.loaded]
      led.off()

    clear: (deviceNumber) ->
      servo = @servos[deviceNumber]
      servo.clear()
      _.invoke(@servoLeds[deviceNumber], 'off')

    tilt: (degrees) ->
      @tilter?.move degrees

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
