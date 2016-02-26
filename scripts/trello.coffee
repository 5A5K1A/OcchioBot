# Description:
#   Mainly for controling the Aanwezigheid board
#
# Dependencies:
#   "node-trello": "0.1.2"
#
# Configuration:
#   HUBOT_TRELLO_KEY - your trello developer key
#
# Commands:
#   trello aanwezig (BG/beneden) - get list 'OP KANTOOR' from 'Aanwezigheid'
#   trello afwezig - get list 'AFWEZIG' from 'Aanwezigheid'
#   trello thuis (klant) - get list 'THUISWERKEN' from 'Aanwezigheid'
#   trello move <Naam> to <state> - <Naam> zoals op de Trello kaart, <state> = `aanwezig` / `afwezig` / `thuis`
#   trello move all to afwezig - zet iedereen op afwezig
#
# Notes:
#   Currently cards can only be added to your default list/board although
#   this can be changed
#
# Author:
#   saskia@occhio

module.exports = (robot) ->
	Trello = require 'node-trello'

	trello_key = process.env.HUBOT_TRELLO_KEY
	trello_token = process.env.HUBOT_TRELLO_TOKEN

	robot.hear /^trello get token/, (msg) ->
		msg.send "Get a token from https://trello.com/1/authorize?key=#{trello_key}&name=Occhio%20Bot&expiration=never&response_type=token&scope=read,write" +
			"Then send it back to me as `trello add token <token>`"

	robot.hear /^trello add token ([a-f0-9]+)/i, (msg) ->
		trellotoken = msg.match[1]
		msg.message.user.trellotoken = trellotoken
		msg.send "Ok, your token is registered"

	robot.hear /^trello forget me/i, (msg) ->
		user = msg.message.user
		user.trellotoken = null
		msg.reply("Ok, I have no idea who you are anymore.")

	robot.hear /^trello get board (.*)/i, (msg) ->
		board_name = msg.match[1]
		user = msg.message.user
		trellotoken = trello_token
		trello = new Trello trello_key, trellotoken
		trello.get '/1/members/me/boards/', (err, data) ->
			for board in data
				if board.name == board_name
					user.trelloboard = board.id
					msg.reply "op #{board.name} (#{board.id}) staan de volgende lijsten:"
					trello.get "/1/boards/#{board.id}/lists", (err, data) ->
						msg.send list.name for list in data

	robot.hear /^trello lists/i, (msg) ->
		user = msg.message.user
		trellotoken = trello_token
		trelloboard = user.trelloboard
		trello = new Trello trello_key, trellotoken
		if !trellotoken
			msg.reply "You have no trellotoken" + "\nUse `trello get token` to get a token."
		else if !trelloboard
			msg.reply "You have no trelloboard" + "\nUse `trello get board <boardname>` to set a board."
		else
			trello.get "/1/boards/#{trelloboard}/lists", (err, data) ->
				msg.send "#{list.name} (#{list.id})" for list in data

	robot.hear /^trello set my list to (.*)/i, (msg) ->
		list_name = msg.match[1]
		user = msg.message.user
		trellotoken = trello_token
		trelloboard = user.trelloboard
		trello = new Trello trello_key, trellotoken
		if !trelloboard
			msg.reply "You have no trelloboard" + "\nUse `trello get board <boardname>` to set a board."
		else
			trello.get "/1/boards/#{trelloboard}/lists", (err, data) ->
				for list in data
					if list.name == list_name
						user.trellolist = list.id
						msg.reply "Your trello list is set to #{list.name}"

	robot.hear /^trello aanwezig/i, (msg) ->
		list_id = '565eb03ef6a6e23e7d04219b'
		msg.send "Ik zal eens even voor je op het Trello bord kijken."
		user = msg.message.user
		trellotoken = trello_token
		trello = new Trello trello_key, trellotoken
		aanwezig = []
		num = 0
		trello.get "/1/lists/#{list_id}/cards", (err, data) ->
			for card in data
				if card.name.match(/^↓/) is null
					aanwezig.push "* #{card.name}"
					num = num + 1
				else
					aanwezig.push card.name
			if num is 0
				msg.send "Er is nu helemaal niemand op kantoor."
			else
				msg.send "Er zijn #{num} mensen op kantoor:\n" +
					aanwezig.join("\n")

	robot.hear /^trello thuis/i, (msg) ->
		list_id = '565eb0554688609aecd8948a'
		msg.send "Ik zal eens even voor je op het Trello bord kijken."
		user = msg.message.user
		trellotoken = trello_token
		trello = new Trello trello_key, trellotoken
		thuis = []
		num = 0
		trello.get "/1/lists/#{list_id}/cards", (err, data) ->
			for card in data
				if card.name.match(/^↓/) is null
					thuis.push "* #{card.name}"
					num = num + 1
				else
					thuis.push card.name
			if num is 0
				msg.send "Er werkt nu niemand thuis."
			else
				msg.send "Deze collega's werken vandaag thuis:\n" +
					thuis.join("\n")

	robot.hear /^trello afwezig/i, (msg) ->
		list_id = '565eb04fe98a114dc96018ab'
		msg.send "Ik zal eens even voor je op het Trello bord kijken."
		user = msg.message.user
		trellotoken = trello_token
		trello = new Trello trello_key, trellotoken
		thuis = []
		num = 0
		trello.get "/1/lists/#{list_id}/cards", (err, data) ->
			for card in data
				thuis.push "* #{card.name}"
				num = num + 1
			if num is 0
				msg.send "Goed zo! Iedereen is aan het werk."
			else
				msg.send "#{num} collega's werken vandaag niet:\n" +
					thuis.join("\n")

	robot.hear /^trello move (.*) to (aanwezig|afwezig|thuis)\s?(.*)?/i, (msg) ->
		user = msg.message.user
		cardmatch = msg.match[1]
		state = msg.match[2]
		specify = 'pos=top'
		trellotoken = trello_token
		trello = new Trello trello_key, trellotoken
		board_id = '565eb03adfd83c6f053bd88a'
		allcards = []
		if state is "aanwezig"
			if msg.match[3]
				specify = 'pos=bottom'
				state += ' op BG'
			list_id = '565eb03ef6a6e23e7d04219b'
			trello.get "/1/boards/#{board_id}/cards", (err, data) ->
				for card in data
					if cardmatch is card.name
						trello.put "/1/cards/#{card.id}?idList=#{list_id}&#{specify}"
						msg.send ":white_check_mark: #{cardmatch} is nu #{state}"
		else if state is "afwezig"
			list_id = '565eb04fe98a114dc96018ab'
			trello.get "/1/boards/#{board_id}/cards", (err, data) ->
				for card in data
					if cardmatch is 'all'
						if card.name.match(/^↓/) is null
							trello.put "/1/cards/#{card.id}?idList=#{list_id}"
					else if cardmatch is card.name
						trello.put "/1/cards/#{card.id}?idList=#{list_id}"
						msg.send "Okidoki! #{cardmatch} staat nu op #{state}"
				if cardmatch is 'all'
					msg.send "Ja hoor, iedereen staat nu op #{state}"
		else if state is "thuis"
			if msg.match[3]
				specify = 'pos=bottom'
				state = 'bij de klant'
			list_id = '565eb0554688609aecd8948a'
			trello.get "/1/boards/#{board_id}/cards", (err, data) ->
				for card in data
					if cardmatch is card.name
						trello.put "/1/cards/#{card.id}?idList=#{list_id}&#{specify}"
						msg.send "Check! #{cardmatch} succes met #{state} werken."
		else
			msg.reply "Sorry, ik begrijp je niet. Maak een keuze uit\n" +
				"`trello move Naam to aanwezig` met eventueel BG/beneden, " +
				"`trello move Naam to afwezig` of " +
				"`trello move Naam to thuis` met eventueel klant/klantnaam"

	robot.hear /^trello me (.*)/i, (msg) ->
		content = msg.match[1]
		user = msg.message.user
		trelloboard = user.trelloboard
		trellotoken = trello_token
		trellolist = user.trellolist
		if !trellotoken
			msg.reply "You don't seem to have a trello token registered. Use \"trello get token\"."
		else if !trelloboard
			msg.reply "You don't seem to have a default trello board configured. Use \"trello my board is\" to do that"
		else if !trellolist
			msg.reply "You don't seem to have a default trello list configured. Use \"trello my list is \" to do that"
		else
			trello = new Trello trello_key, trellotoken
			trello.post "/1/lists/#{trellolist}/cards", { name: content }, (err, data) ->
				msg.reply "Added to your list - #{data.url}"

	robot.hear /^(Wie zet vandaag de lunch klaar?)/i, (msg) ->
		list_id = '565eb03ef6a6e23e7d04219b'
		msg.send "Ik zal eerst eens kijken wie er vandaag allemaal aanwezig zijn."
		trellotoken = trello_token
		trello = new Trello trello_key, trellotoken
		aanwezig = []
		trello.get "/1/lists/#{list_id}/cards", (err, data) ->
			for card in data
				if card.name.match(/^↓/) is null
					aanwezig.push "#{card.name} +1"
				msg.send msg.random aanwezig