board = require './board'

board.on 'ready', -> this.strobeLights(5000)