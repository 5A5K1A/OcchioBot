# Description:
#   Starter scripts for you to examine and try out.
#
# Commands:
#   dance - let's dance
#   DANCE - party time :-)
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

	today = new Date

	robot.hear /^get date/i, (res) ->
		res.send today.getHours()

##### robot hears ... #####
	robot.hear /^hubot? (.+)/i, (res) ->
		response = "Sorry, I'm a diva and only respond to #{robot.name}"
		response += " or #{robot.alias}" if robot.alias
		res.reply response
		return

	introduction = "Let me introduce myself...\nIk ben de enige echte Occhio Bot.\n" +
			"I'm here to help & guide you through the wonders of Slack & Occhio... Let's go!\n" +
			"Als je hulp nodig hebt, kan je met `occhio help` zien wat ik allemaal voor je kan regelen.\n" +
			"_Momenteel bevind ik me nog in de constructie-fase, so bear with me..._"

	error_reply = "ERROR : Computer says noo...\n" +
		"https://media.giphy.com/media/3rgXBAnIuFzJnSTMA0/giphy.gif"

	robot.hear /wie is (.*)occhio/i, (res) ->
		res.send introduction

	robot.hear /wie is (.*) nieuwe bot/i, (res) ->
		res.send introduction

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
			"of je kunt `trello aanwezig` gebruiken."

	dance = [":D|-<", ":D/-<", ":D\-<", ":D>-<"]
	robot.hear /dance\b/, (msg) ->
		msg.emote "gets up and #{msg.random dance}"

	robot.hear /DANCE\b/, (msg) ->
		for move in dance
			msg.emote "dances #{move}"

	robot.hear /error/i, (msg) ->
		msg.send error_reply

	robot.hear /^(sweet|dude)!?/i, (msg) ->
		switch msg.match[1].toLowerCase()
			when "sweet" then msg.send "Dude!"
			when "dude" then msg.send "Sweet!"

	zombies = [
		"http://24.media.tumblr.com/tumblr_m35jnyjTco1qikhvso1_100.gif",
		"http://www.netanimations.net/head2.gif",
		"http://www.netanimations.net/Animated-Zombie-Reverse.gif",
		"http://www.freewebs.com/echoeyy/zombie%20getting%20shot.gif",
		"https://i.chzbgr.com/maxW500/6360720640/h487AE90F/",
		"https://i.chzbgr.com/maxW500/5912815872/h8AB29CB2/",
		"https://i.chzbgr.com/maxW500/5299680512/h5120FD0B/"
	]
	robot.hear /zombi(e|es)/i, (msg) ->
		msg.send msg.random zombies

	yoda_quotes = [
		"Agree with you, the council does. Your apprentice, Skywalker will be.",
		"Always two there are, no more, no less: a master and an apprentice.",
		"Fear is the path to the Dark Side. Fear leads to anger, anger leads to hate; hate leads to suffering. I sense much fear in you.",
		"Qui-Gon's defiance I sense in you.",
		"Truly wonderful the mind of a child is.",
		"Around the survivors a perimeter create.",
		"Lost a planet Master Obi-Wan has. How embarrassing. how embarrassing.",
		"Victory, you say? Master Obi-Wan, not victory. The shroud of the Dark Side has fallen. Begun the Clone War has.",
		"Much to learn you still have...my old padawan... This is just the beginning!",
		"Twisted by the Dark Side young Skywalker has become.",
		"The boy you trained, gone he is, consumed by Darth Vader.",
		"The fear of loss is a path to the Dark Side.",
		"If into the security recordings you go, only pain will you find.",
		"Not if anything to say about it I have.",
		"Great warrior, hmm? Wars not make one great.",
		"Do or do not; there is no try.",
		"Size matters not. Look at me. Judge me by my size, do you?",
		"That is why you fail.",
		"No! No different. Only different in your mind. You must unlearn what you have learned.",
		"Always in motion the future is.",
		"Reckless he is. Matters are worse.",
		"When nine hundred years old you reach, look as good, you will not.",
		"No. There is... another... Sky... walker..."
	]
	robot.hear /yoda/i, (msg) ->
		msg.send "Yoda says: " + msg.random yoda_quotes

##### robot responds (need to be called by name - occhio / @occhio) ... #####
	robot.respond /open the (.*) doors/i, (msg) ->
		doorType = msg.match[1]
		if doorType is "pod bay"
			msg.reply "I'm afraid I can't let you do that."
		else
			msg.reply "Opening #{doorType} doors"

	robot.topic (msg) ->
		msg.send "#{msg.message.text}? Dat is een prima topic voor dit channel!"

	enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hallo vriend.', 'Gotcha', 'Ik zie je']
	leaveReplies = ['Are you still there?', 'Target lost', 'Searching']

	robot.enter (msg) ->
		msg.send msg.random enterReplies
	robot.leave (msg) ->
		msg.send msg.random leaveReplies

	answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING or 42

	robot.respond /what is the answer to the ultimate question of life/, (msg) ->
		unless answer?
			msg.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in evironment: please set and try again"
			return
		msg.send "#{answer}, but what is the question?"

	robot.respond /je bent (.*) traag/, (msg) ->
		setTimeout () ->
			msg.send "Wie noem jij 'traag'?"
		, 60 * 1000

	annoyIntervalId = null

	robot.respond /annoy me/, (msg) ->
		if annoyIntervalId
			msg.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
			return

			msg.send "Hey, want to hear the most annoying sound in the world?"
			annoyIntervalId = setInterval () ->
					msg.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
			, 1000

	robot.respond /unannoy me/, (msg) ->
		if annoyIntervalId
			msg.send "GUYS, GUYS, GUYS!"
			clearInterval(annoyIntervalId)
			annoyIntervalId = null
		else
			msg.send "Not annoying you right now, am I?"

	beerz = ['Sure!', 'Lekker', 'Ja hoor...', 'Vooruit dan', 'Gezellig', 'Zeker']
	drunkz = ['OK, nog eentje dan...', 'Heladijoo, heladijee', 'En we gaan nog niet naar huis, nog languh niet...', 'BURP']

	robot.respond /bier/i, (msg) ->
		beersHad = robot.brain.get('totalBeers') * 1 or 0
		name = msg.message.user.name

		if beersHad > 10
			msg.send 'Zzz... Zzz...'

		else if beersHad > 6
			msg.reply msg.random drunkz
			robot.brain.set 'totalBeers', beersHad+1

		else if beersHad > 5
			msg.reply "Nee tnx, het is genoeg geweest voor vandaag."
			robot.brain.set 'totalBeers', beersHad+1

		else if beersHad > 4
			msg.reply "OMG, nu ben ik echt dronken..."
			robot.brain.set 'totalBeers', beersHad+1

		else if beersHad > 3
			msg.send "Prima @#{name}, maar dat is de laatste..."
			robot.brain.set 'totalBeers', beersHad+1
		else
			msg.reply msg.random beerz
			robot.brain.set 'totalBeers', beersHad+1

	robot.respond /ga slapen/i, (msg) ->
		robot.brain.set 'totalBeers', 0
		msg.send 'Zzz... Zzz... Zzz...'

	robot.respond /wie is @?([\w .\-]+)\?*$/i, (msg) ->
		name = msg.match[1].trim()

		users = robot.brain.usersForFuzzyName(name)
		if users.length is 1
			user = users[0]
			realname = user.real_name
			msg.send "#{name} gaat IRL onder de naam #{realname}"

##### other stuff #####
	robot.router.post '/hubot/chatsecrets/:room', (req, msg) ->
		room   = req.params.room
		data   = JSON.parse req.body.payload
		secret = data.secret

		robot.messageRoom room, "I have a secret: #{secret}"

		msg.send 'OK'

	robot.error (err, msg) ->
		robot.logger.error "DOES NOT COMPUTE"

		if msg?
			msg.reply error_reply