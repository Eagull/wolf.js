junction = require 'junction'
ping = require 'junction-ping'
MucHandler = require 'xmpp-muc-handler'
util = require 'util'

module.exports = (CONFIG) ->

	mucHandler = new MucHandler()

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
		if not connection then throw new Error("connection object is not present")
		connection.on 'error', (err) -> console.error err
		mucHandler.setConnection(connection)

	result =
		client: client
		connection: connection
		mucHandler: mucHandler

