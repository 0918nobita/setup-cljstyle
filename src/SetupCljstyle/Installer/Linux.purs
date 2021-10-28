module SetupCljstyle.Installer.Linux
  ( installBin
  ) where

import Prelude

import Control.Monad.Except (catchError)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error)
import GitHub.Actions.Core (addPath)
import GitHub.Actions.ToolCache (cacheDir, downloadTool, extractTar)
import Milkis (URL(..))
import Node.Os (homedir)
import Node.Path (concat)
import Node.Process (exit)
import SetupCljstyle.Types (Version(..))

downloadUrl :: Version -> URL
downloadUrl (Version version) =
  URL $ "http://github.com/greglook/cljstyle/releases/download/"
    <> version <> "/cljstyle_" <> version <> "_linux.tar.gz"

downloadTar :: Version -> Aff String
downloadTar version =
  let
    url = downloadUrl version
    tryDownloadTar = downloadTool url
  in
  catchError
    tryDownloadTar
    (\_ -> liftEffect do
      error $ "Failed to download " <> show url
      exit 1)

extractCljstyleTar :: String -> String -> Aff String
extractCljstyleTar tarPath binDir =
  catchError
    (extractTar tarPath binDir)
    (\_ -> liftEffect do
      error $ "Failed to extract " <> tarPath
      exit 1)

installBin :: Version -> Effect Unit
installBin version =
  let binDir = concat [homedir unit, "bin"] in
  launchAff_ do
    tarPath <- downloadTar version

    extractedDir <- extractCljstyleTar tarPath binDir

    _ <- cacheDir extractedDir "cljstyle" version

    liftEffect $ addPath extractedDir
