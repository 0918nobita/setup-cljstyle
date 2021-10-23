module Main where

import Prelude

import Actions.Core (InputOption(..), addPath, getInput)
import Actions.ToolCache (downloadTool, find)
import Control.Monad.Except (ExceptT, catchError, except, runExceptT)
import Control.Monad.Trans.Class (lift)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.String.Regex (regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error, log)
import Node.Os (homedir)
import Node.Path (concat)
import Node.Platform (Platform(Win32, Darwin))
import Node.Process (exit, platform)

type Version = String
type Url = String
type ErrorMessage = String

downloadUrl :: Version -> Url
downloadUrl version =
  "http://github.com/greglook/cljstyle/releases/download/"
    <> version <> "/cljstyle_" <> version <> "_linux.tar.gz"

downloadBinary :: Platform -> Version -> Effect Unit
downloadBinary Win32  _       = log "win32"
downloadBinary Darwin _       = log "darwin"
downloadBinary _      version =
  let
    url = downloadUrl version
    destDir = concat [homedir unit, "bin"]
  in do
    log $ "dest dir: " <> destDir
    log $ "Downloading " <> url <> " ..."
    launchAff_ $ catchError
      (do
        tarPath <- downloadTool url
        log $ "Complete (" <> tarPath <> ")")
      (\_ -> liftEffect do
        log $ "Failed to download " <> url
        exit 1)

main :: Effect Unit
main = do
  result <- runExceptT mainExceptT

  case result of
    Right _ -> mempty
    Left e -> do
      error e
      exit 1

  where
    mainExceptT :: ExceptT ErrorMessage Effect Unit
    mainExceptT = do
      version <- lift $ getInput "cljstyle-version" (InputOption { required: false, trimWhitespace: false })

      verRegex <- except $ regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags

      if test verRegex version
        then do
          foundCache <- lift $ find "cljstyle" version
          case foundCache of
            "" ->
              case platform of
                Just p -> lift $ downloadBinary p version
                Nothing ->
                  except $ Left "Failed to identify platform"
            cachePath ->
              lift $ addPath cachePath
        else
          except $ Left "The format of cljstyle-version is invalid."
