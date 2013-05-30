
express = require("express")
http = require("http")
path = require("path")
board = require './board'

app = express()

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", __dirname + "/../../../views"
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")

app.get "/", (req, res) ->
  res.render 'index'

app.get "/startMotor", (req, res) ->
  board.startMotor 30000
  res.end 'done'

app.get "/stopMotor", (req, res) ->
  board.stopMotor()
  res.end 'done'

app.get "/meterLights/:count", (req, res) ->
  board.meterLights parseInt(req.params.count)
  res.end 'done'

app.get "/strobe", (req, res) ->
  board.strobeLights 5000
  res.end 'done'  

app.get "/runway", (req, res) ->
  board.runwayLights()
  res.end 'done'  

board.on 'ready', ->
  http.createServer(app).listen app.get("port"), ->
    console.log "Express server listening on port " + app.get("port")
