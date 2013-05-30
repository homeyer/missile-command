five = require("johnny-five")
    # or "./lib/johnny-five" when running from the source
board = new five.Board()
 
board.on "ready", ->
 
  # Create an Led on pin 13 and strobe it on/off
  # optionally set the speed; defaults to 100ms
  (new five.Led(13)).strobe()