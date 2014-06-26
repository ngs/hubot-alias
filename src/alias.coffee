# Description:
#   Action alias for hubot
#
# Commands:
#   hubot alias xxx=yyy - Make alias xxx for yyy
#   hubot alias xxx= - Remove alias xxx for yyy
#   hubot alias clear - Clear the alias table
#
# Author:
#   dtaniwaki

ALIAS_TABLE_KEY = 'hubot-alias-table'

module.exports = (robot) ->
  receiveOrg = robot.receive
  robot.receive = (msg)->
    table = robot.brain.get(ALIAS_TABLE_KEY) || {}
    orgText = msg.text?.trim()
    if /hubot(\s)([^\s]*)(.*)$/.test orgText
      sp = RegExp.$1
      action = RegExp.$2
      rest = RegExp.$3
      msg.text = "hubot#{sp}#{table[action] || action}#{rest}" if action != 'alias'
    console.log "Change \"#{orgText}\" as \"#{msg.text}\"" if orgText != msg.text

    receiveOrg.bind(robot)(msg)

  robot.respond /alias(.*)$/i, (msg)->
    text = msg.match[1].trim()
    table = robot.brain.get(ALIAS_TABLE_KEY) || {}
    if /clear/.test text
      robot.brain.set ALIAS_TABLE_KEY, {}
      msg.send "I cleared the alias table"
    else if !text
      msg.send JSON.stringify(table)
    else
      match = text.match /([^\s=]*)=([^\s]*)?/
      alias = match[1]
      action = match[2]
      if action?
        msg.send "I made alias #{alias} for #{action}"
        table[alias] = action
        robot.brain.set ALIAS_TABLE_KEY, table
      else
        msg.send "I removed alias #{alias}"
        delete table[alias]
        robot.brain.set ALIAS_TABLE_KEY, table
