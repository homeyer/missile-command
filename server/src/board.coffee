five = require "johnny-five"
EventEmitter = require("events").EventEmitter

module.exports = (->

  class MissileBoard extends EventEmitter

    constructor: ->
      @board = new five.Board()

      @board.on "ready", => this.emit('ready')
       
    strobeLights: (ms = 10000) ->
       
        # Create an Led on pin 13 and strobe it on/off
        # optionally set the speed; defaults to 100ms
        led = new five.Led(12)

        console.log 'Strobing LED'
        led.strobe()

        @board.wait ms, ->

          console.log 'Stopping LED'
          led.stop().off()

    motorize: (ms = 5000) ->
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

  new MissileBoard()
)()
