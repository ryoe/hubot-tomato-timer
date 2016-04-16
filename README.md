[hubot]: https://github.com/github/hubot
[coffeestyle]: https://github.com/polarmobile/coffeescript-style-guide
[tomatotimer]: http://tomato-timer.com/

# hubot-tomato-timer

A [Hubot][hubot] script for all your tomato timer needs. Simply start a timer and Hubot will notify you when the timer is done.

Inspired by [TomatoTimer][tomatotimer].

## Install It

Install with **npm** using ```--save``` to add to your ```package.json``` dependencies.
```
  > npm install --save hubot-tomato-timer
```

Then add **"hubot-tomato-timer"** to your ```external-scripts.json```.

Example external-scripts.json
```json
["hubot-tomato-timer"]
```

Or if you prefer, just drop **tomato-timer.coffee** in your [Hubot][hubot] scripts folder and enjoy.

## Use It

Each user can start a single timer per chat room. Everyone in a chatroom can start their own timer. 

* `hubot tomato start` - start a tomato timer
* `hubot tomato stop` - stop a tomato timer
* `hubot tomato all` -  show all the tomato timers, everywhere
* `hubot tomato help` - return the allowed commands

Or if you prefer, these work too:
* `hubot start tomato` - start a tomato timer
* `hubot stop tomato` - stop a tomato timer
* `hubot all tomato` - show all the tomato timers, everywhere
* `hubot help tomato` - return the allowed commands

## Configure It

If you don't like the default `:tomato:` emoji, you can override using `HUBOT_TOMATO_TIMER_EMOJI`.

## Improve It

Feel free to help this script suck less by opening issues and/or sending pull requests. 

If you haven't already, be sure to checkout the [Hubot scripting guide](https://github.com/github/hubot/blob/master/docs/scripting.md) for tons of info about extending [Hubot][hubot].

## Coding Style

Other than the 79 character line length limit, which I consider to be a suggestion, let's try to follow the [CoffeeScript Style Guide][coffeestyle].

## Other Hubot tomato timers

I found **[hubot-pomodoro](https://www.npmjs.com/package/hubot-pomodoro)** when trying to decide on a package name. Give it a shot if you don't like **hubot-tomato-timer** (or even if you do).


