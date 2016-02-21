# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

module.exports = (robot) ->

	robot.hear /^hubot? (.+)/i, (res) ->
		response = "Sorry, I'm a diva and only respond to #{robot.name}"
		response += " or #{robot.alias}" if robot.alias
		res.reply response
		return

	robot.hear /wie is occhiobot/i, (res) ->
		res.send "Let me introduce myself..."

	robot.hear /badger/i, (res) ->
		res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"

	robot.respond /open the (.*) doors/i, (res) ->
		doorType = res.match[1]
		if doorType is "pod bay"
			res.reply "I'm afraid I can't let you do that."
		else
			res.reply "Opening #{doorType} doors"

	robot.hear /I like pie/i, (res) ->
		res.emote "makes a freshly baked pie"

	lulz = ['lol', 'rofl', 'lmao']

	robot.respond /lulz/i, (res) ->
		res.send res.random lulz

	robot.topic (res) ->
		res.send "#{res.message.text}? Dat is een prima topic voor dit channel!"

	enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
	leaveReplies = ['Are you still there?', 'Target lost', 'Searching']

	robot.enter (res) ->
		res.send res.random enterReplies
	robot.leave (res) ->
		res.send res.random leaveReplies

	answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING or 42

	robot.respond /what is the answer to the ultimate question of life/, (res) ->
		unless answer?
			res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in evironment: please set and try again"
			return
		res.send "#{answer}, but what is the question?"

	robot.respond /you are a little slow/, (res) ->
		setTimeout () ->
			res.send "Who you calling 'slow'?"
		, 60 * 1000

	annoyIntervalId = null

	robot.respond /annoy me/, (res) ->
		if annoyIntervalId
			res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
			return

			res.send "Hey, want to hear the most annoying sound in the world?"
			annoyIntervalId = setInterval () ->
					res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
			, 1000

	robot.respond /unannoy me/, (res) ->
		if annoyIntervalId
			res.send "GUYS, GUYS, GUYS!"
			clearInterval(annoyIntervalId)
			annoyIntervalId = null
		else
			res.send "Not annoying you right now, am I?"


	robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
		room   = req.params.room
		data   = JSON.parse req.body.payload
		secret = data.secret

		robot.messageRoom room, "I have a secret: #{secret}"

		res.send 'OK'

	robot.error (err, res) ->
		robot.logger.error "DOES NOT COMPUTE"

		if res?
			res.reply "DOES NOT COMPUTE"

	beerz = ['Sure!', 'Lekker', 'Ja hoor...', 'Vooruit dan', 'Gezellig', 'Zeker']

	drunkz = ['OK, nog eentje dan...', 'Heladijoo, heladijee', 'En we gaan nog niet naar huis, nog languh niet...', 'BURP']

	robot.respond /bier/i, (res) ->
		# Get number of beers had (coerced to a number).
		beersHad = robot.brain.get('totalBeers') * 1 or 0

		name = res.message.user.name

		if beersHad > 10
			res.send 'Zzz... Zzz...'

		else if beersHad > 6
			res.reply res.random drunkz
			robot.brain.set 'totalBeers', beersHad+1

		else if beersHad > 5
			res.reply "Nee tnx, het is genoeg geweest voor vandaag."
			robot.brain.set 'totalBeers', beersHad+1

		else if beersHad > 4
			res.reply "OMG, nu ben ik echt dronken..."
			robot.brain.set 'totalBeers', beersHad+1

		else if beersHad > 3
			res.send "Prima @#{name}, maar dat is de laatste..."
			robot.brain.set 'totalBeers', beersHad+1
		else
			res.reply res.random beerz
			robot.brain.set 'totalBeers', beersHad+1

	robot.respond /ga slapen/i, (res) ->
		robot.brain.set 'totalBeers', 0
		res.send 'Zzz... Zzz... Zzz...'

	robot.respond /wie is @?([\w .\-]+)\?*$/i, (res) ->
		name = res.match[1].trim()

		users = robot.brain.usersForFuzzyName(name)
		if users.length is 1
			user = users[0]
			realname = user.real_name
			email = user.email

			if email == undefined
				email = "info@occhio.nl o.v.v. #{realname}"

			res.send "#{name} is gaat IRL onder de naam #{realname}\n#{realname} is te mailen op #{email}"

	robot.hear /hallo/i, id: 'my-hello', rateLimits: {minPeriodMs: 100000}, (res) ->

		name = res.message.user.name

		# This will execute no faster than once every hundred seconds
		res.send "Hee, hallootjes @#{name}!"