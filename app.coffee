'use strict'

process.env.NODE_ENV ?= 'dev'

junction = require 'junction'
WolfController = require './game/controller'

# load configuration
require 'js-yaml'
XMPP_CONFIG = require './config/xmpp.yaml'
GAME_CONFIG = require './config/game.yaml'

web = require('./frontend/web')(process.env.PORT, process.env.IP)
xmppClient = require('./frontend/xmpp')(XMPP_CONFIG)
mucHandler = xmppClient.mucHandler

xmppClient.connection.on 'online', ->

	adminRoom = mucHandler.joinRoom(XMPP_CONFIG.adminRoom, XMPP_CONFIG.nickname)
	adminRoom.on 'rosterReady', initializeAdminRoom

	gameRoom = mucHandler.joinRoom(XMPP_CONFIG.gameRoom, XMPP_CONFIG.nickname)
	gameRoom.on 'rosterReady', initializeGameRoom

initializeAdminRoom = (selfUser) ->
	console.log "joined admin room:", @roomId

initializeGameRoom = (selfUser) ->

	if(selfUser.affiliation isnt 'owner' and selfUser.affiliation isnt 'admin')
			@part("Grant me power before you demand my presence, fools.")
			console.error("Must be at least an admin in game room:", @roomId)

	console.log "joined game room:", @roomId

	# initializing new controller for the game room
	game = new WolfController(this, GAME_CONFIG)

	# binding game's public events to websockets
	for event in game.EVENTS
		game.on event, (data) ->
			web.io.sockets.emit(event, data)

