'use strict'

# Load configuration.
config = require './wolf.js/configuration'

process.env.NODE_ENV ?= 'dev'

util = require 'util'
junction = require 'junction'
ping = require 'junction-ping'
MucHandler = require 'xmpp-muc-handler'
express = require 'express'

mucHandler = new MucHandler()

if not process.env.XMPP_USER or not process.env.XMPP_PASSWD
	console.error "environment variables required: XMPP_USER, XMPP_PASSWD"
	process.exit 2

xmppOptions =
	type: 'client'
	jid: process.env.XMPP_USER
	password: process.env.XMPP_PASSWD

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

connection = client.connect(xmppOptions).on 'online', ->
	util.log 'Connected as: ' + @jid
	@send new junction.elements.Presence()
	if not connection then return console.error "Not connected"
	room = 'test@chat.eagull.net'
	nick = 'Monkey'
	connection.send new junction.elements.Presence("#{room}/#{nick}")
	connection.on 'error', (err) -> console.error err
	room = mucHandler.addRoom room
	room.on 'rosterReady', (user) ->
		util.log "SelfStatus: " + JSON.stringify user
		util.log "Roster: " + JSON.stringify @roster
	room.on 'status', (user) ->
		util.log "Status: " + JSON.stringify user
		util.log "Roster: " + JSON.stringify @roster
	room.on 'joined', (user) ->
		util.log "Joined: " + JSON.stringify user
		util.log "Roster: " + JSON.stringify @roster
	room.on 'parted', (data) ->
		util.log "Parted: " + data.nick
		util.log "Roster: " + JSON.stringify @roster
	room.on 'nickChange', (data) ->
		util.log "NickChange: #{data.nick} to #{data.newNick}"
		util.log "Roster: " + JSON.stringify @roster
	room.on 'subject', (data) ->
		util.log "[#{@roomId}] #{data.subject} (set by #{data.nick})"
	room.on 'privateMessage', (data) ->
		util.log "[#{data.nick}] #{data.text}"
	room.on 'groupMessage', (data) ->
		out = "<#{data.nick}> #{data.text}"
		if data.delay then out += " (sent at #{data.delay})"
		util.log out

app.listen process.env.PORT or 0, process.env.IP, ->
	addr = app.address()
	util.log "[#{process.env.NODE_ENV}] http://#{addr.address}:#{addr.port}/"
