# Description:
#   Hubot will handle your tomato (Pomodoro) timer needs
#
# Commands:
#   hubot tomato start - start a tomato timer
#   hubot tomato stop - stop a tomato timer
#   hubot tomato all - show all the tomato timers, everywhere
#   hubot tomato short break - start a short break timer
#   hubot tomato long break - start a long break timer
#   hubot tomato stop break - stop a tomato break timer
#   hubot tomato help - return the allowed commands
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
tomatoInterval = Math.floor(25*60*1000)
# 5 minutes is standard Pomodoro short break
shortBreakInterval = Math.floor(5*60*1000)
# 10 minutes is standard Pomodoro long break
longBreakInterval = Math.floor(10*60*1000)
timers = {}
breakTimers = {}
botName = 'botName not set'
bot = null

help = [
  'tomato start - start a tomato timer'
  'tomato stop - stop a tomato timer'
  'tomato all - show all the tomato timers, everywhere'
  'tomato short break - start a short break timer'
  'tomato long break - start a long break timer'
  'tomato stop break - stop a tomato break timer'
  'tomato help - return the allowed commands'
]

stringCompare = (a, b) ->
  return a.toLowerCase() is b

cleanUpBreakTimer = (key, intervalId) ->
  #stop break timer and remove the key from breakTimers map
  clearInterval intervalId
  delete breakTimers[key]

breakTimerCallback = (key) ->
  userInfo = breakTimers[key]

  if userInfo?
    cleanUpBreakTimer key, userInfo.intervalId
    bot.messageRoom userInfo.room, "Hey #{userInfo.name}! Your #{tomatoEmoji} break time is over!"
  else
    console.log "WAT?!?!?"

startBreakTimer = (msg, userInfo, breakInterval) ->
  breakTimer = breakTimers[userInfo.key]

  if breakTimer?
    msg.send "#{tomatoEmoji} break timer already started for #{userInfo.name} in ##{userInfo.room}. Try `#{botName} tomato stop break`"
  else
    msg.send "Starting #{tomatoEmoji} break timer for #{userInfo.name} in ##{userInfo.room}"
    breakTimers[userInfo.key] = userInfo
    intervalId = setInterval breakTimerCallback, breakInterval, userInfo.key
    breakTimers[userInfo.key].intervalId = intervalId
    breakTimers[userInfo.key].startTime = Date.now()
    breakTimers[userInfo.key].expectedStop = breakTimers[userInfo.key].startTime + breakInterval

startShortBreak = (msg, userInfo) ->
  startBreakTimer msg, userInfo, shortBreakInterval

startLongBreak = (msg, userInfo) ->
  startBreakTimer msg, userInfo, longBreakInterval

stopBreak = (msg, userInfo) ->
  breakTimer = breakTimers[userInfo.key]

  if breakTimer?
    msg.send "Stopping #{tomatoEmoji} break timer for #{userInfo.name} in ##{userInfo.room}"
    cleanUpBreakTimer userInfo.key, breakTimer.intervalId
  else
    msg.send "No #{tomatoEmoji} break timer exists for #{userInfo.name} in ##{userInfo.room}. Try `#{botName} tomato short break` or `#{botName} tomato long break`"

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
    msg.send "#{tomatoEmoji} timer already started for #{userInfo.name} in ##{userInfo.room}. Try `#{botName} tomato stop`"
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
    msg.send "No #{tomatoEmoji} timer exists for #{userInfo.name} in ##{userInfo.room}. Try `#{botName} tomato start`"

showAllTimers = (msg, userInfo) ->
  keys = Object.keys timers

  if keys? and keys.length > 0
    deets = ("#{key}: " + timeRemaining(timers[key].expectedStop) + " remaining" for key in keys).join "\n* "
    msg.send "Here are all the #{tomatoEmoji} timers!\n\n* #{deets}"
  else
    msg.send "No #{tomatoEmoji} timers exist!. Try `#{botName} tomato start`"

showMyTimers = (msg, userInfo) ->
  allKeys = Object.keys timers

  unless allKeys? and allKeys.length > 0
    msg.send "No #{tomatoEmoji} timers exist!. Try `#{botName} tomato start`"
    return

  keys = allKeys.filter (key) -> return key if timers[key].name == userInfo.name

  if keys? and keys.length > 0
    deets = ("#{key}: " + timeRemaining(timers[key].expectedStop) + " remaining" for key in keys).join "\n* "
    msg.reply "Here are your #{tomatoEmoji} timers!\n\n* #{deets}"
  else
    msg.send "No #{tomatoEmoji} timers exist!. Try `#{botName} tomato start`"

showTimerInfo = (msg, userInfo) ->
  timer = timers[userInfo.key]

  if timer?
    deets = timeRemaining(timer.expectedStop) + " remaining"
    msg.reply "Your #{tomatoEmoji} timer info: #{deets}"
  else
    msg.send "No #{tomatoEmoji} timers exist!. Try `#{botName} tomato start`"

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
  if cmd and stringCompare cmd, 'info'
    showTimerInfo msg, userInfo
    return
  if cmd and stringCompare cmd, 'mine'
    showMyTimers msg, userInfo
    return
  if cmd and stringCompare cmd, 'long break'
    startLongBreak msg, userInfo
    return
  if cmd and stringCompare cmd, 'short break'
    startShortBreak msg, userInfo
    return
  if cmd and stringCompare cmd, 'stop break'
    stopBreak msg, userInfo
    return
  if cmd and stringCompare cmd, 'all'
    showAllTimers msg, userInfo
    return

  msg.send "I don't understand #{cmd}. Try `#{botName} tomato help`"

module.exports = (robot) ->
  botName = robot.name
  bot = robot

  robot.respond /(short break|long break|stop break|all|start|stop|info|mine|help){1} (tomato|timer|Pomodoro|:tomato:){1}/i, (msg) ->
    cmd     = msg.match[1] or null
    cmdArgs = msg.match[2] or null

    processCommands msg, cmd, cmdArgs

  robot.respond /(tomato timer|tomato|:tomato: timer|:tomato:|timer|Pomodoro){1} (short break|long break|stop break|all|start|stop|info|mine|help){1}/i, (msg) ->
    cmd     = msg.match[2] or null
    cmdArgs = msg.match[1] or null

    processCommands msg, cmd, cmdArgs

