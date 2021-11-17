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
  , "github-actions-toolkit"
  , "identity"
  , "maybe"
  , "node-buffer"
  , "node-child-process"
  , "node-fs"
  , "node-path"
  , "node-process"
  , "prelude"
  , "psci-support"
  , "spec"
  , "strings"
  , "transformers"
  , "yaml-next"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
