$ ->
  window.votes = window.localStorage['votes']
  if !window.votes?
    window.votes = {}
  else
    try
      window.votes = JSON.parse(window.votes)  
    catch e
      window.votes = {}

  window.created = window.localStorage['created']
  if !window.created?
    window.created = {}
  else
    try
      window.created = JSON.parse(window.created)  
    catch e
      window.created = {}

  window.submitAction = ->
     window.submit $('#submission-box').val()
     $('#submission-box').val("")

  window.createCallbacks = ->
    $('.up-arrow').off("click")
    $('.down-arrow').off("click")
    $('.remove').off("click")

    $('.up-arrow').click (e) ->
      if window.vote_lock
        return
      voted_id = parseInt $(this).closest('.submission-row').attr('id'), 10
      if window.votes[voted_id] > 0
        alert "You've already upvoted this."
      else if window.created[voted_id]?
        alert "You created this post."
      else
        for s in window.submissions
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
      else if window.created[voted_id]?
        alert "You created this post."
      else
        for s in window.submissions
          if s.id == voted_id
            console.log "Downvoting: "
            console.log s
            window.downvote(s)
            return

    $('.remove').click (e) ->
      remove_id = parseInt $(this).closest('.submission-row').attr('id'), 10
      console.log "remove clicked for " + remove_id
      for s in window.submissions
        if s.id == remove_id
          console.log "Removing: "
          console.log s
          window.remove(s)
          return