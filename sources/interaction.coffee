$ ->
  window.votes = window.localStorage['votes']
  if !window.votes?
    window.votes = {}
  else
    try
      window.votes = JSON.parse(window.votes)  
    catch e
      window.votes = {}

  window.submitAction = ->
     window.submit $('#submission-box').val()

  window.createCallbacks = ->
    $('.up-arrow').off("click")
    $('.down-arrow').off("click")

    $('.up-arrow').click (e) ->
      if window.vote_lock
        return
      voted_id = parseInt $(this).closest('.submission-row').attr('id'), 10
      if window.votes[voted_id] > 0
        alert "You've already upvoted this."
      else
        for s in window.submissions
          console.log s
          if s.id == voted_id
            console.log "Upvoting: "
            console.log s
            window.upvote(s)
            return

    $('.down-arrow').click (e) ->
      if window.vote_lock
        return
      voted_id = parseInt $(this).closest('.submission-row').attr('id'), 10
      if window.votes[voted_id] < 0
        alert "You've already downvoted this."
      else
        for s in window.submissions
          console.log s
          if s.id == voted_id
            console.log "Downvoting: "
            console.log s
            window.downvote(s)
            return