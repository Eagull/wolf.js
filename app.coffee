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

gameRooms = {}

xmppClient.connection.on 'online', ->

	adminRoom = mucHandler.joinRoom XMPP_CONFIG.adminRoom, XMPP_CONFIG.nickname
	adminRoom.on 'rosterReady', initializeAdminRoom

	for room in XMPP_CONFIG.gameRooms
		gameRooms[room] = mucHandler.joinRoom room, XMPP_CONFIG.nickname
		gameRooms[room].on 'rosterReady', initializeGameRoom

initializeAdminRoom = (selfUser) ->
	console.log "joined admin room:", @roomId

	@on 'groupMessage', (data) ->
		text = data.text.trim()
		return if data.delay or not text.length
		affiliation = @roster[data.nick].affiliation
		if affiliation in ['owner', 'admin', 'member'] and text[0] is '!'
			console.log "<#{data.nick}> #{text}"
			cmd = text.split ' '
			switch cmd[0].substr(1)
				when 'join'
					room = cmd[1]
					nick = XMPP_CONFIG.nickname
					gameRooms[room] = mucHandler.joinRoom room, XMPP_CONFIG.nickname
					gameRooms[room].on 'rosterReady', initializeGameRoom
				when 'part'
					room = cmd[1]
					if room of gameRooms
						gameRooms[room].part()
					else
						@sendGroup "Can't part a room that I'm not a part of. Did you really mean #{room}?"

initializeGameRoom = (selfUser) ->

	if selfUser.affiliation isnt 'owner' and selfUser.affiliation isnt 'admin'
		@part("Grant me power before you demand my presence, fools.")
		return console.error "Must be an admin in game room:", @roomId

	console.log "joined game room:", @roomId

	# initializing new controller for the game room
	game = new WolfController this, GAME_CONFIG

	# binding game's public events to websockets
	for event in game.EVENTS
		game.on event, (data) ->
			web.io.sockets.emit event, data

