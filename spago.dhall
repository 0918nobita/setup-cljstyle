{ name = "setup-cljstyle"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "argonaut"
  , "console"
  , "control"
  , "effect"
  , "either"
  , "errors"
  , "maybe"
  , "node-buffer"
  , "node-fs"
  , "node-path"
  , "node-process"
  , "prelude"
  , "psci-support"
  , "strings"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
