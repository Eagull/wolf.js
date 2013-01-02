express = require 'express'
util = require 'util'

module.exports = (port = 0, ip) ->
	app = express.createServer()
	io = require('socket.io').listen(app)

	app.configure 'dev', ->
		app.use express.logger('dev')
		io.set 'log level', 2

	app.configure 'production', ->
		app.use express.logger()
		io.set 'log level', 1
		io.enable 'browser client minification'
		io.enable 'browser client etag'
		io.enable 'browser client gzip'

	app.get '/*', (req, res) ->
		res.send "I live!"

	app.listen port, ip, ->
		addr = app.address()
		util.log "[#{process.env.NODE_ENV}] http://#{addr.address}:#{addr.port}/"

	result =
		app: app
		io: io
		subscribe: (game) ->
			for event in game.EVENTS
				game.on event, (data) ->
					io.sockets.emit(event, data)

