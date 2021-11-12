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
  , "maybe"
  , "node-buffer"
  , "node-child-process"
  , "node-fs"
  , "node-path"
  , "node-process"
  , "node-streams"
  , "prelude"
  , "psci-support"
  , "spec"
  , "strings"
  , "transformers"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
