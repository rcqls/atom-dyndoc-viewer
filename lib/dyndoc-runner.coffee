spawn = (require 'child_process').spawn
exec = (require 'child_process').exec
path = require 'path'

dyndoc_env = process.env

console.log(dyndoc_env)

module.exports=
class DyndocRunner

  @dyndoc_server = null
  @dyndoc_client = null
  @dyndoc_run_cmd = 'ruby' #if process.platform == 'win32' then 'rubyw' else 'ruby'

  @start: ->
  	dyndoc_env["DYN_HOME"] =  atom.config.get('dyndoc-viewer.dyndocHome')
  	## To fix PATH when /usr/local/bin not inside PATH
  	for pa in atom.config.get('dyndoc-viewer.addToPath').split(":")
  	  dyndoc_env["PATH"] += ":" + pa if dyndoc_env["PATH"].split(":").indexOf(pa) < 0
  	    
  	@dyndoc_server = spawn @dyndoc_run_cmd,[path.join atom.config.get('dyndoc-viewer.dyndocHome'),"bin","dyndoc-server-simple.rb"],{"env": dyndoc_env}
  	
  	@dyndoc_server.stderr.on 'data', (data) ->
  	  console.log 'dyndoc-server stderr: ' + data

  	@dyndoc_server.stdout.on 'data', (data) ->
  	  console.log 'dyndoc-server stdout: ' + data

  @started: ->
  	console.log ["started",@dyndoc_server]
  	if @dyndoc_server == null or @dyndoc_server.killed
  	  @start()

  @stop: ->
    console.log 'DyndocRunner is leaving...'
    if @dyndoc_client != null
      @dyndoc_client.close
      console.log 'DyndocRunner client is closed!'
    @dyndoc_server.kill()
    console.log 'DyndocRunner is killed!'

  @compile: (dyn_file) ->
  	compile_cmd=@dyndoc_run_cmd + " " + path.join(atom.config.get('dyndoc-viewer.dyndocHome'),"bin","dyndoc-compile.rb") + " " + dyn_file
  	exec compile_cmd, {"env": dyndoc_env}, (error,stdout,stderr) ->
  	  console.log 'dyndoc-compile stdout: ' + stdout
  	  console.log 'dyndoc-compile stderr: ' + stderr
  	  if error != null
  	  	console.log 'dyndoc-compile error: ' + error
