# The Dodgy Voter

## The Project

This is a very simple Hacker News or Reddit style submission and voting site with upvotes, downvotes, and no login necessary. I built it so that everyone in a class I taught during MIT's IAP (Interim Activities Period, aka January) in 2013 could vote on each other's ideas.

It's really, really straightforward, but works.

Security? What's that? Seriously, though, it's super easy for the client to manipulate the results. They can't do it by just clicking buttons on the page, but I make no other guarantees.

It's written in CoffeeScript for both client and server and uses Socket.io for realtime communication (everything is live).

## To Run

1. `git clone` this repository
2. `npm install` to install all needed packages
3. `coffee app.coffee` to run on port 8000

