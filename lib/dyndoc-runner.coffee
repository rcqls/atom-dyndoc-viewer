spawn = (require 'child_process').spawn

dyndoc_env = process.env

console.log(dyndoc_env)

module.exports=
class DyndocRunner

  @dyndoc_server = null

  @start: ->
  	@dyndoc_server = spawn atom.config.get('dyndoc-viewer.dyndocRunCmd'),[atom.config.get('dyndoc-viewer.dyndocRunScript')],{"env": dyndoc_env}
  	
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

