events = require 'events'

module.exports = class Player extends events.EventEmitter
	constructor: (@playerId, @name) ->
		events.EventEmitter.call(this)
		@alive = true
		@acted = false
		@ammoCount = 0

	see: -> @constructor.name

	kill: ->
		@alive = false
		this.emit 'killed'

	visit: ->

