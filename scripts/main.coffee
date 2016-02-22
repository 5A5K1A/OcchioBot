# Description:
#   Starter scripts for you to examine and try out.
#
# Commands:
#   hubot bier(tje) - domibo fun ;-p
#   hubot ga slapen - stuur @occhio naar bed
#   hubot what is the answer to the ultimate question of life - the answer to the ultimate question of life
#   wie is vandaag op kantoor - verwijzing naar Trello board 'Aanwezigheid'
#   wie is occhio - introductie van @occhio
#   hubot wie is <user> - gegevens <user>
#
# Notes:
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md
#
# Author:
#   saskia@occhio

module.exports = (robot) ->

##### robot hears ... #####
	robot.hear /^hubot? (.+)/i, (res) ->
		response = "Sorry, I'm a diva and only respond to #{robot.name}"
		response += " or #{robot.alias}" if robot.alias
		res.reply response
		return

	robot.hear /wie is occhio/i, (res) ->
		res.send "Let me introduce myself...\nIk ben de enige echte Occhio Bot.\n" +
			"I'm here to help & guide you through the wonders of Slack & Occhio... Let's go!\n" +
			"Als je hulp nodig hebt, kun je met `occhio help` zien wat ik allemaal voor je kan regelen.\n" +
			"Momenteel bevind ik me nog in de constructie-fase, so bear with me..."

	robot.hear /badger/i, (res) ->
		res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"

	robot.hear /taart/i, (res) ->
		res.emote "een versgebakken taart maken doet"

	robot.hear /hallo/i, id: 'my-hello', rateLimits: {minPeriodMs: 100000}, (res) ->
		name = res.message.user.name
		res.send "Hee, hallootjes @#{name}!"

	robot.hear /doei/i, id: 'my-hello', rateLimits: {minPeriodMs: 100000}, (res) ->
		name = res.message.user.name
		res.send "Superdoei @#{name}!"

	robot.hear /wie (.*) vandaag op kantoor/i, (res) ->
		res.send "Dan moet je even op het Trello bord (https://trello.com/b/6MvsMMx1/aanwezigheid) kijken,\n" +
			"of je kunt `occhio trello aanwezig` gebruiken."

##### robot responds (need to be called by name - occhio / @occhio) ... #####
	robot.respond /open the (.*) doors/i, (res) ->
		doorType = res.match[1]
		if doorType is "pod bay"
			res.reply "I'm afraid I can't let you do that."
		else
			res.reply "Opening #{doorType} doors"

	robot.topic (res) ->
		res.send "#{res.message.text}? Dat is een prima topic voor dit channel!"

	enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hallo vriend.', 'Gotcha', 'Ik zie je']
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

	robot.respond /je bent (.*) traag/, (res) ->
		setTimeout () ->
			res.send "Wie noem jij 'traag'?"
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

	beerz = ['Sure!', 'Lekker', 'Ja hoor...', 'Vooruit dan', 'Gezellig', 'Zeker']
	drunkz = ['OK, nog eentje dan...', 'Heladijoo, heladijee', 'En we gaan nog niet naar huis, nog languh niet...', 'BURP']

	robot.respond /bier/i, (res) ->
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

			res.send "#{name} is gaat IRL onder de naam #{realname}\n" +
				"en is te mailen op #{email}"

##### other stuff #####
	robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
		room   = req.params.room
		data   = JSON.parse req.body.payload
		secret = data.secret

		robot.messageRoom room, "I have a secret: #{secret}"

		res.send 'OK'

	robot.error (err, res) ->
		robot.logger.error "DOES NOT COMPUTE"

		if res?
			res.reply "Computer says noo...\n" +
				"https://media.giphy.com/media/3rgXBAnIuFzJnSTMA0/giphy.gif"