# Description:
#   Add entries to trello directly from hubot
#
# Dependencies:
#   "node-trello": "0.1.2"
#
# Configuration:
#   HUBOT_TRELLO_KEY - your trello developer key
#
# Commands:
#   trello get board <board> - get the specified Trello board
#   trello aanwezig - get list 'OP KANTOOR' from 'Aanwezigheid'
#   trello afwezig - get list 'AFWEZIG' from 'Aanwezigheid'
#   trello thuis - get list 'THUISWERKEN' from 'Aanwezigheid'
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

	robot.hear /^trello all the users/i, (msg) ->
		theReply = "Here is who I know:\n"

		for own key, user of robot.brain.data.users
			if(user.trellotoken)
				theReply += user.name + "\n"

		msg.send theReply

	robot.hear /^trello get token/, (msg) ->
		msg.send "Get a token from https://trello.com/1/authorize?key=#{trello_key}&name=cicsbot&expiration=30days&response_type=token&scope=read,write"
		msg.send "Then send it back to me as \"trello add token <token>\""

	robot.hear /^trello add token ([a-f0-9]+)/i, (msg) ->

		trellotoken = msg.match[1]
		msg.message.user.trellotoken = trellotoken
		msg.send "Ok, your token is registered"

	robot.hear /^trello forget me/i, (msg) ->
		user = msg.message.user
		user.trellotoken  = null

		msg.reply("Ok, I have no idea who you are anymore.")

#	robot.hear /^trello boards/i, (msg) ->
#		user = msg.message.user
#		trellotoken = trello_token
#		trello = new Trello trello_key, trellotoken
#		trello.get '/1/organizations/occhionl/boards/public', (err,data) ->
#			console.log board for board in data
#			msg.send board.name for board in data

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
			msg.reply "You have no trellotoken"
		else if !trelloboard
			msg.reply "You have no trelloboard"
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
			msg.reply "You have no trelloboard"
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
		trello.get "/1/lists/#{list_id}/cards", (err, data) ->
			for card in data
				aanwezig.push "* #{card.name}"
			msg.send "De volgende mensen zijn op kantoor:\n" +
				aanwezig.join("\n")

	robot.hear /^trello thuis/i, (msg) ->
		list_id = '565eb0554688609aecd8948a'
		msg.send "Ik zal eens even voor je op het Trello bord kijken."
		user = msg.message.user
		trellotoken = trello_token
		trello = new Trello trello_key, trellotoken
		thuis = []
		trello.get "/1/lists/#{list_id}/cards", (err, data) ->
			for card in data
				thuis.push "* #{card.name}"
			msg.send "Deze collega's werken vandaag thuis:\n" +
				thuis.join("\n")

	robot.hear /^trello afwezig/i, (msg) ->
		list_id = '565eb04fe98a114dc96018ab'
		msg.send "Ik zal eens even voor je op het Trello bord kijken."
		user = msg.message.user
		trellotoken = trello_token
		trello = new Trello trello_key, trellotoken
		thuis = []
		trello.get "/1/lists/#{list_id}/cards", (err, data) ->
			for card in data
				thuis.push "* #{card.name}"
			msg.send "Deze collega's werken vandaag niet:\n" +
				thuis.join("\n")

	robot.hear /^trello set me to (.*)/i, (msg) ->
		state = msg.match[1]
		user = msg.message.user
		trellotoken = trello_token
		trello = new Trello trello_key, trellotoken
		board_id = '565eb03adfd83c6f053bd88a'
		excuse = "still working on this... "
		if state is "aanwezig"
			list_id = '565eb03ef6a6e23e7d04219b'
			msg.send user.first_name + " (" + board_id + ")"
			trello.get "/1/search?query=#{user}&idBoards=#{board_id}", (err, data) ->
				for card in data
					msg.send card.name
				msg.reply excuse + "set state to #{state}"
		else if state is "afwezig"
			list_id = '565eb04fe98a114dc96018ab'
			msg.reply excuse + "set state to #{state}"
		else if state is "thuis"
			list_id = '565eb0554688609aecd8948a'
			msg.reply excuse + "set state to #{state}"
		else
			msg.reply "Sorry, ik begrijp je niet. Maak een keuze uit\n" +
				"`trello set me to aanwezig`, " +
				"`trello set me to afwezig` of " +
				"`trello set me to thuis`"

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