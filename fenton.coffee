optimist = require('optimist')
argv = optimist
       .usage('Fenton lets you programmatically manage your /etc/hosts file.\nUsage: $0')
       .describe('add',     'Add a hostname (--add google.com 127.0.0.1)')
       .describe('delete' , 'Remove a host entry (--delete google.com)')
       .describe('list',    'Show all of the host entries managed by fenton')
       .describe('import',  'Import a JSON file into fenton')
       .argv

fs = require('fs')
class HostsFile

	constructor: (@filename) ->

		# Holds all of the host entries in the form of hostname: ip_address
		@entries = {}

		# TODO: handle file error when it's not readable

		# We use synchronous i/o here because we don't want to modify the hosts file
		# until it's been completely parsed.
		@contents = fs.readFileSync @filename
		@entries = @parse @contents.toString()

	add: (hostname, address) ->
		console.log "Adding #{hostname} as #{address} to #{@filename} file..."
		@entries[hostname] = address
		console.log @entries
		@sync()

	delete: (hostname) ->
		console.log "Deleting #{hostname} from #{@filename}"

		if hostname.match /\*/
			hostname = hostname.replace /\*/, "(.+)"
			regex = new RegExp(hostname)
			for entry of @entries
				if entry.match regex then delete @entries[entry]

		delete @entries[hostname]
		@sync()

	sync: ->
		fs.writeFileSync @filename, @toHostsFile()

	toHostsFile: ->

		hosts = "# fenton start token #\n"
		for hostname, ip_address of @entries
			hosts = hosts + "#{ip_address}\t#{hostname}\n"
		hosts = hosts + "# fenton end token #\n"

		#console.log(hosts)

		return @contents.toString().replace /# fenton start token #[^]+# fenton end token #/mg, hosts

	toString: ->
		@entries

	parse: (hosts) ->

		lines = hosts.split(/\n/)

		has_found_token = false
		has_ever_found_token = false
		found_entries = {}

		for line in lines

			if has_found_token == false
				if line == "# fenton start token #"
					has_found_token = true
					has_ever_found_token = true
				continue
			
			if line == "# fenton end token #" then has_found_token = false
			
			continue unless line.indexOf "#"
			continue if line == ""

			contents = line.split(/\s+/g)
			
			found_entries[contents[1]] = contents[0]

		if has_ever_found_token == false
			@contents += "\n\n# fenton start token #\n# fenton end token #"
		found_entries

hosts = new HostsFile "/etc/hosts"

commands = 
	"add": ->
		# TODO Error Checking
		hosts.add(argv["add"], argv._[0])
		#console.log(hosts.toHostsFile())
	"list": ->
		console.log hosts.toString()
	"delete": ->
		hostname = argv["delete"]
		hosts.delete hostname
		console.log hosts.toString()
	"import": ->
		fs.readFile argv["import"], (err, data) ->
			json = JSON.parse(data)

			for hostname, ip_address of json
				hosts.add(hostname, ip_address)
	"export": ->
		fs.writeFile argv["export"], JSON.stringify(hosts.toString(), null, 4)
			

found_command = false

for command, func of commands
	if command of argv
		func()
		found_command = true


if found_command == false
	console.log(optimist.help())