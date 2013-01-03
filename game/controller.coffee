# subscribes to the given room, processes PMs and commands
# checks authorization and state before executing a command
# depends on game core to provide game state and dynamics
# uses timer and event handler to keep track of time and change game state
# emits events captured by socket.io for publishing game status
# one controller per room
'use strict'

WolfCore = require './core'
events = require 'events'

module.exports = class WolfController extends events.EventEmitter

	EVENTS: ['waiting', 'day', 'night', 'ended']

	constructor: (@room, @connection, @config = {}) ->

		@core = null

		@lastCommandTime =
			stat: 0
			ping: 0

		@lastSeen = {}
		@away = []

		# TODO: subscribe to room's events

	reset: ->
		@core = new WolfCore @settings

