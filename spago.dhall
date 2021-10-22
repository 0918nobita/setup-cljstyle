{ name = "setup-cljstyle"
, dependencies = [
    "console",
    "effect",
    "either",
    "maybe",
    "node-path",
    "node-process",
    "prelude",
    "psci-support",
    "strings"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
