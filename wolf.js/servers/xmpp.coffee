class module.exports
	# List of allowed properties
	@allowedConfigProperties:
		# Room name should contain "@"
		room: (name) ->
			throw new Error 'Room name should contain @' unless /@/.test name

		# Username also should contain "@"
		username: (name) ->
			throw new Error 'Username should contain @' unless /@/.test name

		# TODO: Fill this with actual nickname requirements
		nickname: true

		# Passwords shouldn't have any requirements
		password: true
