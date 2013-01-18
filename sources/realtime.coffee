window.vote_lock = false
$ ->
  window.submissions = []
  socket = io.connect("http://localhost:8001")

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
        window.submissions.push(submission)
    console.log "update received"
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

  socket.on 'error', (data) ->
    console.error "Error received: "
    console.error data
    alert "An error occurred. Please reload."

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
    
    """
    <li id='""" + submission.id + """' class="submission-row">
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

  window.submit = (submission_title) ->
    socket.emit 'submit', {
      title: submission_title
    }
