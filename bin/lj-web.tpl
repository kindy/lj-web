#!__luajit_bin__

package.path = '__lualib_dir__?.lua;__lualib_dir__?/index.lua;;'
package.cpath = '__lualib_dir__?.so;;'

require 'lj.web.cmd'.run(arg)

