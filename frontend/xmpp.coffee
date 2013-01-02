junction = require 'junction'
ping = require 'junction-ping'
MucHandler = require 'xmpp-muc-handler'
mucHandler = new MucHandler()
util = require 'util'

module.exports = (CONFIG) ->

	client = junction.create()

	client.use ping()

	client.use junction.presenceParser()
	client.use junction.messageParser()
	client.use mucHandler

	client.use junction.serviceUnavailable()

	client.use junction.errorHandler
		includeStanza: true
		showStack: true
		dumpExceptions: true

	xmppOptions =
		type: 'client'
		jid: CONFIG.username
		password: CONFIG.password

	connection = client.connect(xmppOptions).on 'online', ->
		util.log 'Connected as: ' + @jid
		@send new junction.elements.Presence()
		if not connection then return console.error "Not connected"
		connection.on 'error', (err) -> console.error err
		connection.send new junction.elements.Presence(CONFIG.room + "/" + CONFIG.nickname)

	result =
		client: client
		connection: connection
		gameRoom: mucHandler.addRoom(CONFIG.room)

