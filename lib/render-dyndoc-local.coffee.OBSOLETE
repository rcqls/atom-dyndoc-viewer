ref=require("ref")
ffi=require("ffi")

mrbState='void'
mrbStatePtr=ref.refType(mrbState)
mrbValue = ref.refType("void")
mrbValuePtr=ref.refType(mrbValue)

mrb_ffi=ffi.Library process.env["MRB4FFI_LIB"] || "/Users/remy/devel/mruby/build/host/lib/libmruby",
  mrb_open: [mrbStatePtr,[]]
  mrb_close: ["void",[mrbStatePtr]]
  mrb_init_dyndoc: ["int",[mrbStatePtr]]
  mrb_process_dyndoc: ["string",[mrbStatePtr,"string"]]

exports.eval = (text='', filePath, callback) ->
  mrb = mrb_ffi.mrb_open()
  #mrb_ffi.mrb_init_dyndoc(mrb)
  text=text.replace /\#\{/g,"__AROBAS_ATOM__{"
  #res = mrb_ffi.mrb_process_dyndoc(mrb,text)
  #mrb_ffi.mrb_close(mrb)
  res = text
  callback(null, text)
  return res
  
