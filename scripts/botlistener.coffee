HubotSlack = require 'hubot-slack'

module.exports = (robot) ->

  regex = /^(Failed:|Timed out:).*/

  robot.listeners.push new HubotSlack.SlackBotListener robot, regex, (msg) ->
    msg.send "blah"