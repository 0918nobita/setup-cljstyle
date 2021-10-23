module Main where

import Prelude

import Actions.Core (InputOption(..), addPath, getInput)
import Actions.ToolCache (find)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.String.Regex (regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Class.Console (error, log)
import Node.Os (homedir)
import Node.Path (concat)
import Node.Platform (Platform(Win32, Darwin))
import Node.Process (platform)

downloadUrl :: String -> String
downloadUrl version =
  "http://github.com/greglook/cljstyle/releases/download/"
    <> version <> "/cljstyle_" <> version <> "_linux.tar.gz"

downloadBinary :: Platform -> String -> Effect Unit
downloadBinary Win32  _       = log "win32"
downloadBinary Darwin _       = log "darwin"
downloadBinary _      version =
  let url = downloadUrl version in
    do
      log $ "download url: " <> url
      log $ "homedir: " <> concat [homedir unit, "bin"]

main :: Effect Unit
main = do
  version <- getInput "cljstyle-version" (InputOption { required: false, trimWhitespace: false })

  case regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags of
    Right version_regex | test version_regex version ->
      do
        foundCache <- find "cljstyle" version
        case foundCache of
          "" ->
            case platform of
              Just p -> downloadBinary p version
              Nothing -> error "Failed to identify platform"
          cachePath ->
            addPath cachePath
    Right _ ->
      error "The format of cljstyle-version is invalid."
    Left _ ->
      error "Failed to construct a Regex"
