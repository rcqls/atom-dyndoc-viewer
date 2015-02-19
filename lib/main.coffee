url = require 'url'
path = require 'path'
fs = require 'fs'

dyndoc_viewer = null
DyndocViewer = require './dyndoc-viewer' #null # Defer until used
rendererCoffee = require './render-coffee'
rendererDyndoc = require './render-dyndoc'
DyndocRunner = require './dyndoc-runner'

#rendererDyndoc = null # Defer until user choose mode local or server

createDyndocViewer = (state) ->
  DyndocViewer ?= require './dyndoc-viewer'
  dyndoc_viewer = new DyndocViewer(state)

isDyndocViewer = (object) ->
  DyndocViewer ?= require './dyndoc-viewer'
  object instanceof DyndocViewer

atom.deserializers.add
  name: 'DyndocViewer'
  deserialize: (state) ->
    createDyndocViewer(state) if state.constructor is Object

module.exports =
  config:
    dyndoc: 
      type: 'string'
      default: 'local' # or 'server'
    dyndocHome:
      type: 'string'
      default: if fs.existsSync(path.join process.env["HOME"],".dyndoc_home") then String(fs.readFileSync(path.join process.env["HOME"],".dyndoc_home")).trim() else path.join process.env["HOME"],"dyndoc" 
    addToPath: 
      type: 'string'
      default: '/usr/local/bin:' + path.join(process.env["HOME"],"bin") # you can add anoter path with ":"
    localServer: 
      type: 'boolean' 
      default: true
    localServerUrl: 
      type: 'string'
      default: 'localhost'
    localServerPort: 
      type: 'integer'
      default: 7777
    remoteServerUrl:
      type: 'string'
      default: 'sagag6.upmf-grenoble.fr'
    remoteServerPort: 
      type: 'integer'
      default: 5555
    breakOnSingleNewline:
      type: 'boolean' 
      default: false
    liveUpdate: 
      type: 'boolean' 
      default: true
    grammars:
      type: 'array'
      default: [
        'source.dyndoc'
        'source.gfm'
        'text.html.basic'
        'text.html.textile'
      ]

  activate: ->
    atom.commands.add 'atom-workspace', 
      'dyndoc-viewer:eval': =>
        @eval()
      'dyndoc-viewer:compile': =>
        @compile()
      'dyndoc-viewer:atom-dyndoc': =>
        @atomDyndoc()
      'dyndoc-viewer:coffee': =>
        @coffee()
      'dyndoc-viewer:toggle': =>
        @toggle()
      'dyndoc-viewer:toggle-break-on-single-newline': ->
        keyPath = 'dyndoc-viewer.breakOnSingleNewline'
        atom.config.set(keyPath,!atom.config.get(keyPath))


    #atom.workspaceView.on 'dyndoc-viewer:preview-file', (event) =>
    #  @previewFile(event)
 
    atom.workspace.registerOpener (uriToOpen) ->
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        return

      return unless protocol is 'dyndoc-viewer:'

      try
        pathname = decodeURI(pathname) if pathname
      catch error
        return

      if host is 'editor'
        createDyndocViewer(editorId: pathname.substring(1))
      else
        createDyndocViewer(filePath: pathname)

    DyndocRunner.start()

  deactivate: ->
    DyndocRunner.stop()

  coffee: ->
    selection = atom.workspace.getActiveEditor().getSelection()
    text = selection.getText()
    console.log rendererCoffee.eval text

  atomDyndoc: ->
    selection = atom.workspace.getActiveEditor().getSelection()
    text = selection.getText()
    if text == ""
      text = atom.workspace.getActiveEditor().getText()
    #util = require 'util'

    text='[#require]Tools/Atom\n[#main][#>]{#atomInit#}\n'+text
    ##console.log "text:  "+text
    rendererDyndoc.eval text, atom.workspace.getActiveEditor().getPath(), (error, content) ->
      if error
        console.log "err: "+content
      else
        #console.log "before:" + content
        content=content.replace /__DIESE_ATOM__/g, '#'
        content=content.replace /__AROBAS_ATOM__\{/g, '#{'

        #
        console.log "echo:" + content
        #fs = require "fs"
        #fs.writeFile "/Users/remy/test_atom.coffee", content, (error) ->
        #  console.error("Error writing file", error) if error
        rendererCoffee.eval content

  eval: ->
    return unless dyndoc_viewer
    selection = atom.workspace.getActiveEditor().getSelection()
    text = selection.getText()
    if text == ""
      text = atom.workspace.getActiveEditor().getText()
    dyndoc_viewer.render(text)
    #res = renderer.toText text, "toto", (error, content) ->
    #  if error
    #    console.log "err: "+content
    #  else
    #   console.log "echo:" + content

  compile: -> 
    dyn_file = atom.workspace.getActiveEditor().getPath()
    DyndocRunner.compile dyn_file

  toggle: ->
    if isDyndocViewer(atom.workspace.activePaneItem)
      atom.workspace.destroyActivePaneItem()
      return

    editor = atom.workspace.getActiveEditor()
    return unless editor?

    #grammars = atom.config.get('dyndoc-viewer.grammars') ? []
    #return unless editor.getGrammar().scopeName in grammars

    @addPreviewForEditor(editor) unless @removePreviewForEditor(editor)

  uriForEditor: (editor) ->
    "dyndoc-viewer://editor/#{editor.id}"

  removePreviewForEditor: (editor) ->
    uri = @uriForEditor(editor)
    console.log(uri)
    previewPane = atom.workspace.paneForUri(uri)
    console.log("preview-pane: "+previewPane)
    if previewPane?
      previewPane.destroyItem(previewPane.itemForUri(uri))
      true
    else
      false

  addPreviewForEditor: (editor) ->
    uri = @uriForEditor(editor)
    previousActivePane = atom.workspace.getActivePane()
    atom.workspace.open(uri, split: 'right', searchAllPanes: true).done (DyndocViewer) ->
      if isDyndocViewer(DyndocViewer)
        #DyndocViewer.renderDyndoc()
        previousActivePane.activate()


  # previewFile: ({target}) ->
  #   filePath = $(target).view()?.getPath?() #Maybe to replace with: filePath = target.dataset.path
  #   return unless filePath

  #   for editor in atom.workspace.getEditors() when editor.getPath() is filePath
  #     @addPreviewForEditor(editor)
  #     return

  #   atom.workspace.open "dyndoc-viewer://#{encodeURI(filePath)}", searchAllPanes: true
