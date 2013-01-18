window.vote_lock = false
$ ->
  window.submissions = []
  socket = io.connect("/")
  socket = io.connect()

  socket.on "listing", (data) ->
    console.log data
    window.submissions = data
    buildPage()
  
  socket.on 'new-submission', (submission) ->
    for s in window.submissions
      if s.id == submission.id
        return
    window.submissions.push submission
    addSubmissionToPage(submission) 

  socket.on 'update', (submission) ->
    for s in window.submissions
      if s.id == submission.id
        window.submissions.splice(window.submissions.indexOf(s), 1)
        break
    window.submissions.push(submission)
    console.log "update received"
    console.log window.submissions
    buildPage()

  socket.on 'created', (submission) ->
    for s in window.submissions
      if s.id == submission.id
        window.submissions.splice(window.submissions.indexOf(s), 1)
        break
    window.submissions.push(submission)
    window.created[submission.id] = true
    window.localStorage['created'] = JSON.stringify(window.created)
    console.log "created received"
    console.log window.submissions
    buildPage()

  socket.on 'remove', (submission) ->
    for s in window.submissions
      if s.id == submission.id
        window.submissions.splice(window.submissions.indexOf(s), 1)
        break
    console.log "remove received"
    console.log window.submissions
    buildPage()

  # socket.on 'downvote', (submission) ->
  #   for s in window.submissions
  #     if s.id == submission.id
  #       window.submissions.splice(window.submissions.indexOf(s), 1)
  #       window.submissions.push(submission)
  #   console.log "downvote received"
  #   console.log window.submissions
  #   buildPage()

  # socket.on 'error', (data) ->
  #   console.error "Error received: "
  #   console.error data
  #   alert "An error occurred. Please reload."

  buildPage = ->
    window.vote_lock = true
    $('#submission-list').empty()
    window.submissions.sort (a, b) ->
      return -1 * ((a.upvotes - a.downvotes) - (b.upvotes - b.downvotes))
    for submission in window.submissions
      addSubmissionToPage(submission)
    setTimeout ->
      window.vote_lock = false
    , 1000
      
  addSubmissionToPage = (submission) ->
    console.log "about to add: "
    console.log submission
    $('#submission-list').append buildRow(submission)
    $("body").timeago()
    window.createCallbacks()
      
  buildRow = (submission) ->
    upvoted_selected_string = ""
    downvoted_selected_string = ""
    if window.votes[submission.id]? and window.votes[submission.id] > 0
      upvoted_selected_string = " selected"
    else if window.votes[submission.id]? and window.votes[submission.id] < 0
      downvoted_selected_string = " selected"
    remove_string = ""
    if window.created[submission.id]?
      remove_string = """<div class="remove">x</div>"""
    
    """
    <li id='""" + submission.id + """' class="submission-row">
      """ + remove_string + """
      <div class="arrows">
        <div class='up-arrow""" + upvoted_selected_string + """'></div>
        <div class="score">""" + (submission.upvotes - submission.downvotes) + """</div>
        <div class='down-arrow""" + downvoted_selected_string + """'></div>
      </div>
      <div class="submission-title">""" + submission.title + """</div>
    </li>
    """

  deupvote = (submission) ->
    socket.emit 'deupvote', submission

  dedownvote = (submission) ->
    socket.emit 'dedownvote', submission
  
  window.upvote = (submission) ->
    if window.votes[submission.id]? and window.votes[submission.id] < 0
      dedownvote(submission)
    window.votes[submission.id] = 1
    window.localStorage['votes'] = JSON.stringify(window.votes)
    socket.emit 'upvote', submission

  window.downvote = (submission) ->
    if window.votes[submission.id]? and window.votes[submission.id] > 0
      deupvote(submission)
    window.votes[submission.id] = -1
    window.localStorage['votes'] = JSON.stringify(window.votes)
    socket.emit 'downvote', submission

  window.remove = (submission) ->
    window.created[submission.id] = undefined
    socket.emit 'remove', submission

  window.submit = (submission_title) ->
    socket.emit 'submit', {
      title: submission_title
    }
