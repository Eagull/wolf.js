# keeps track of game state
# doesn't keep time; depends on controller to call hooks at right time
# cannot be reused; initialize new core for each new game
'use strict'

fs = require 'fs'

Role = {}
fs.readdir __dirname + '/roles', (err, roleFiles) ->
	if err then throw err
	for roleFile in roleFiles
		try
			roleClass = require __dirname + '/roles/' + roleFile
			Role[roleClass.name] = roleClass
		catch error
			console.error error
			continue

module.exports = class WolfCore

	STATES: ['new', 'waiting', 'day', 'night', 'ended']

	constructor: (@room) ->

		@startedAt = Date.now()
		@players = []
		@lynch = []


		@currentState = @STATES[0]

		@roles =
			seer: []
			wolf: []
			cursed: []
			drunk: []
			harlot: []
			traitor: []
			gunner: []
			crow: []
			angel: []
			detective: []

	start: ->
	leave: (player) ->
	join: (player) ->
	shoot: (player, target) ->
	vote: (player, target) ->
	retract: (player) ->
	visit: (player, target) ->
	guard: (player, target) ->
	identify: (player, target) ->

	initialize: ->
	endNight: ->
	endDay: ->
	isGameOver: ->

