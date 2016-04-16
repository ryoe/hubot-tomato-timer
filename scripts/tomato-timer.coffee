# Description:
#   Hubot will handle your tomato (Pomodoro) timer needs
#
# Commands:
#   hubot tomato stop - stop a tomato timer
#   hubot stop tomato - stop a tomato timer
#   hubot tomato start - start a tomato timer
#   hubot start tomato - start a tomato timer
#   hubot tomato all -  show all the tomato timers, everywhere
#   hubot all tomato - show all the tomato timers, everywhere
#   hubot tomato help - return the allowed commands
#   hubot help tomato - return the allowed commands
#
# Configuration:
#   HUBOT_TOMATO_TIMER_EMOJI - set the tomato timer emoji. default: `:tomato:`
#
# Dependencies:
#   none
#
# Notes:
#   have fun with it
#
# Author:
#   ryoe
tomatoEmoji = process.env.HUBOT_TOMATO_TIMER_EMOJI or ':tomato:'

# 25 minutes is standard Pomodoro
# 25 minutes in milliseconds = 25*60*1000 = 1500000
tomatoInterval = 1500000
timers = {}
botName = 'botName not set'
bot = null

help = [
  'start tomato - start a tomato timer'
  'stop tomato - stop a tomato timer'
  'all tomato - show all the tomato timers, everywhere'
  'help tomato - return the allowed commands'
  'tomato start - start a tomato timer'
  'tomato stop - stop a tomato timer'
  'tomato all - show all the tomato timers, everywhere'
  'tomato help - return the allowed commands'
]

stringCompare = (a, b) ->
  return a.toLowerCase() is b

cleanUpTimer = (key, intervalId) ->
  #stop timer and remove the key from timers map
  clearInterval intervalId
  delete timers[key]

timeRemaining = (expectedStop) ->
  secsRemaining = Math.floor((expectedStop - Date.now())/1000)
  minutesRemaining = Math.ceil(secsRemaining/60)
  return "Less than #{minutesRemaining} min (#{secsRemaining} sec)" unless minutesRemaining is 1
  return "#{secsRemaining} sec" unless minutesRemaining isnt 1

tomatoTimerCallback = (key) ->
  userInfo = timers[key]

  if userInfo?
    cleanUpTimer key, userInfo.intervalId
    bot.messageRoom userInfo.room, "Hey #{userInfo.name}! Your #{tomatoEmoji} is done!"
  else
    console.log "WAT?!?!?"

startTimer = (msg, userInfo) ->
  timer = timers[userInfo.key]

  if timer?
    msg.send "Tomato timer already started for #{userInfo.name} in ##{userInfo.room}. Try `#{botName} stop tomato`"
  else
    msg.send "Starting #{tomatoEmoji} timer for #{userInfo.name} in ##{userInfo.room}"
    timers[userInfo.key] = userInfo
    intervalId = setInterval tomatoTimerCallback, tomatoInterval, userInfo.key
    timers[userInfo.key].intervalId = intervalId
    timers[userInfo.key].startTime = Date.now()
    timers[userInfo.key].expectedStop = timers[userInfo.key].startTime + tomatoInterval

stopTimer = (msg, userInfo) ->
  timer = timers[userInfo.key]

  if timer?
    msg.send "Stopping #{tomatoEmoji} timer for #{userInfo.name} in ##{userInfo.room}"
    cleanUpTimer userInfo.key, timer.intervalId
  else
    msg.send "No #{tomatoEmoji} timer exists for #{userInfo.name} in ##{userInfo.room}. Try `#{botName} start tomato`"

showAllTimers = (msg, userInfo) ->
  keys = Object.keys timers

  if keys? and keys.length > 0
    deets = ("#{key}: " + timeRemaining(timers[key].expectedStop) + " remaining" for key in keys).join "\n* "
    msg.send "Here are all the #{tomatoEmoji} timers!\n\n* #{deets}"
  else
    msg.send "No #{tomatoEmoji} timers exist!. Try `#{botName} start tomato`"

processCommands = (msg, cmd, cmdArgs) ->
  user = msg.message.user.name
  room = msg.message.user.room
  key = "#{user}_#{room}"
  userInfo = 
    key: key
    name: user
    room: room

  if cmd and stringCompare cmd, 'help'
    deets =  ("#{botName} #{h}" for h in help).join '\n'
    msg.send "I came here to drink milk and start tomato timers. And I've just finished my milk.\n\n#{deets}"
    return
  if cmd and stringCompare cmd, 'start'
    startTimer msg, userInfo
    return
  if cmd and stringCompare cmd, 'stop'
    stopTimer msg, userInfo
    return
  if cmd and stringCompare cmd, 'all'
    showAllTimers msg, userInfo
    return

  msg.send "I don't understand #{cmd}. Try `#{botName} tomato help`"

module.exports = (robot) ->
  botName = robot.name
  bot = robot

  robot.respond /(all|start|stop|help){1} (tomato|timer|Pomodoro|:tomato:){1}/i, (msg) ->
    cmd     = msg.match[1] or null
    cmdArgs = msg.match[2] or null

    processCommands msg, cmd, cmdArgs

  robot.respond /(tomato timer|tomato|:tomato: timer|:tomato:|timer|Pomodoro){1} (all|start|stop|help){1}/i, (msg) ->
    cmd     = msg.match[2] or null
    cmdArgs = msg.match[1] or null

    processCommands msg, cmd, cmdArgs

