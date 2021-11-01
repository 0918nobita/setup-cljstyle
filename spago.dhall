{ name = "setup-cljstyle"
, dependencies =
  [ "aff"
  , "argonaut"
  , "argonaut-codecs"
  , "console"
  , "control"
  , "effect"
  , "either"
  , "errors"
  , "foreign-object"
  , "github-actions-toolkit"
  , "maybe"
  , "milkis"
  , "node-buffer"
  , "node-fs"
  , "node-path"
  , "node-process"
  , "prelude"
  , "psci-support"
  , "spec"
  , "strings"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
