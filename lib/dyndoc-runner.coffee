spawn = (require 'child_process').spawn
path = require 'path'

dyndoc_env = process.env

console.log(dyndoc_env)

module.exports=
class DyndocRunner

  @dyndoc_server = null
  @dyndoc_run_cmd = if process.platform == 'win32' then 'rubyw' else 'ruby'

  @start: ->
  	dyndoc_env["DYN_HOME"] =  atom.config.get('dyndoc-viewer.dyndocHome')
  	## To fix PATH when /usr/local/bin not inside PATH
  	for pa in atom.config.get('dyndoc-viewer.addToPath').split(":")
  	  dyndoc_env["PATH"] += ":" + pa if dyndoc_env["PATH"].split(":").indexOf(pa) < 0
  	    
  	@dyndoc_server = spawn @dyndoc_run_cmd,[path.join atom.config.get('dyndoc-viewer.dyndocHome'),"bin","dyndoc-server-simple.rb"],{"env": dyndoc_env}
  	
  	@dyndoc_server.stderr.on 'data', (data) ->
  	  console.log 'dyndoc stderr: ' + data

  	@dyndoc_server.stdout.on 'data', (data) ->
  	  console.log 'dyndoc stdout: ' + data


  @started: ->
  	console.log ["started",@dyndoc_server]
  	if @dyndoc_server == null or @dyndoc_server.killed
  	  @start()

  @stop: ->
    console.log 'DyndocRunner is leaving...'
    @dyndoc_server.kill()
    console.log 'DyndocRunner is killed!'

