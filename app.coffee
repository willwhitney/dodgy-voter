express = require 'express'
socketio = require 'socket.io'
lessMiddleware = require 'less-middleware'
io = require 'socket.io'

app = express()
server = require('http').createServer(app)

port = process.env.PORT || 8000
io = io.listen server, { log: true }
io.configure ->
  io.set("transports", ["xhr-polling"])
  io.set("polling duration", 10)
  
server.listen port

submissions = []

io.sockets.on 'connection', (socket) ->
  socket.emit 'listing', submissions

  socket.on 'submit', (submission) ->
    console.log submission
    submission.id = nextId()
    submission.upvotes = 0
    submission.downvotes = 0
    submissions.push submission
    socket.broadcast.emit 'new-submission', submission
    socket.emit 'created', submission

  socket.on 'upvote', (submission) ->
    console.log 'upvoted: ' 
    console.log submission

    goldSubmission = null
    for s in submissions
      if s.id == submission.id
        goldSubmission = s
    if goldSubmission == null
      socket.emit("error")
      return

    goldSubmission.upvotes++
    socket.broadcast.emit 'update', goldSubmission
    socket.emit 'update', goldSubmission

  socket.on 'deupvote', (submission) ->
    console.log 'deupvoted: ' 
    console.log submission

    goldSubmission = null
    for s in submissions
      if s.id == submission.id
        goldSubmission = s
    if goldSubmission == null
      socket.emit("error")
      return

    goldSubmission.upvotes--
    # socket.broadcast.emit 'update', goldSubmission
    # socket.emit 'update', goldSubmission

  socket.on 'downvote', (submission) ->
    console.log 'downvoted: '
    console.log submission

    goldSubmission = null
    for s in submissions
      if s.id == submission.id
        goldSubmission = s
    if goldSubmission == null
      socket.emit("error")
      return

    goldSubmission.downvotes++
    socket.broadcast.emit 'update', goldSubmission
    socket.emit 'update', goldSubmission

  socket.on 'dedownvote', (submission) ->
    console.log 'dedownvoted: '
    console.log submission

    goldSubmission = null
    for s in submissions
      if s.id == submission.id
        goldSubmission = s
    if goldSubmission == null
      socket.emit("error")
      return

    goldSubmission.downvotes--
    # socket.broadcast.emit 'update', goldSubmission
    # socket.emit 'update', goldSubmission

  socket.on 'remove', (submission) ->
    console.log 'removed: '
    console.log submission

    for s in submissions
      if s.id == submission.id
        submissions.splice(submissions.indexOf(s), 1)
        break

    socket.broadcast.emit 'remove', submission
    socket.emit 'remove', submission


app.configure ->
	app.set 'views', __dirname + '/views'
	# app.set 'view engine', 'jade'
	app.use("/styles", lessMiddleware({ src: __dirname + '/styles'}))
	app.use("/styles", express.static(__dirname + '/styles'))
	app.use("/static", express.static(__dirname + '/static'))
	app.use("/img", express.static(__dirname + '/img'))
	app.use("/sources", express.static(__dirname + '/sources'))
	app.use("/", express.static(__dirname + '/static'))



lastId = 0
nextId = () ->
  ++lastId