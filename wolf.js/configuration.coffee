'use strict'
# Configuration parser

# Require YAML support if available.
try require 'js-yaml'

module.exports = require '../config'

# List of properties that should be always allowed
alwaysAllow =
	type: yes
	prefix: yes

for server in module.exports
	# Lowercase server types to follow JS conventions
	server.type = server.type.toLowerCase()

	# Load list of allowed properties from the configuration
	{allowedConfigProperties} = require "./servers/#{server.type}"
	for property, value of server
		check = allowedConfigProperties[property] or alwaysAllow[property]
		# Property is unknown if check for it doesn't exist.
		throw new Error "Unknown property '#{property}'" unless check

		# Let the function check the value if it is a function.
		check? value
