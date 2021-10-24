module SetupCljstyle.Linux
  ( installBin
  ) where

import Prelude

import Actions.ToolCache (downloadTool)
import Control.Monad.Except (catchError)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error, info)
import Node.Os (homedir)
import Node.Path (concat)
import Node.Process (exit)
import SetupCljstyle.Types (Version, Url)

downloadUrl :: Version -> Url
downloadUrl version =
  "http://github.com/greglook/cljstyle/releases/download/"
    <> version <> "/cljstyle_" <> version <> "_linux.tar.gz"

installBin :: Version -> Effect Unit
installBin version =
  let
    url = downloadUrl version
    destDir = concat [homedir unit, "bin"]
  in do
    info $ "dest dir: " <> destDir
    info $ "Downloading " <> url <> " ..."
    launchAff_ $ catchError
      (do
        tarPath <- downloadTool url
        info $ "Complete (" <> tarPath <> ")")
      (\_ -> liftEffect do
        error $ "Failed to download " <> url
        exit 1)
