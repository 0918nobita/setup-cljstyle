module Main where

import Prelude

import Actions.Core (InputOption(..), addPath, getInput)
import Actions.ToolCache (find)
import Control.Monad.Except (ExceptT(..), runExceptT)
import Control.Monad.Trans.Class (lift)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.String.Regex (Regex, regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Class.Console (error, log)
import Node.Os (homedir)
import Node.Path (concat)
import Node.Platform (Platform(Win32, Darwin))
import Node.Process (platform)

foo :: ExceptT String Effect Unit
foo = lift $ log "foo"

bar :: ExceptT String Effect Regex
bar = ExceptT $ pure $ regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags

baz :: ExceptT String Effect Unit
baz = do
  _ <- bar
  foo

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
      log $ "dest dir: " <> concat [homedir unit, "bin"]

main :: Effect Unit
main = do
  a <- runExceptT foo
  case a of
    Right _ -> mempty
    Left _ -> error "Failed to call `log`"

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
