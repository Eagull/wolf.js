'use strict'

process.env.NODE_ENV ?= 'dev'

junction = require 'junction'
WolfController = require './game/controller'

# load configuration
require 'js-yaml'
XMPP_CONFIG = require './config/xmpp.yaml'
GAME_CONFIG = require './config/game.yaml'

web = require('./frontend/web')(process.env.PORT, process.env.IP)
gameRoom = require('./frontend/xmpp')(XMPP_CONFIG).gameRoom

game = null

gameRoom.on 'rosterReady', ->
	# check affiliation, fail if not owner
	game = new WolfController(gameRoom, GAME_CONFIG)
	web.subscribe(game)

