module SetupCljstyle.Installer.Darwin where

import Control.Monad.Except.Trans (ExceptT, withExceptT)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import GitHub.Actions.Core (addPath)
import GitHub.Actions.ToolCache (cacheDir, downloadTool, extractTar)
import Milkis (URL(..))
import Prelude
import SetupCljstyle.Types (ErrorMessage(..), Version(..))

downloadUrl :: Version -> URL
downloadUrl (Version version) =
  URL $ "http://github.com/greglook/cljstyle/releases/download/"
    <> version
    <> "/cljstyle_"
    <> version
    <> "_macos.tar.gz"

downloadTar :: Version -> ExceptT ErrorMessage Aff String
downloadTar version =
  let
    URL url = downloadUrl version
    tryDownloadTar = downloadTool { url, auth: Nothing, dest: Nothing }
  in
    tryDownloadTar # withExceptT (\_ -> ErrorMessage $ "Failed to download " <> url)

extractCljstyleTar :: String -> String -> ExceptT ErrorMessage Aff String
extractCljstyleTar tarPath binDir =
  extractTar { file: tarPath, dest: Just binDir, flags: Nothing }
    # withExceptT (\_ -> ErrorMessage $ "Failed to extract " <> tarPath)

installBin :: Version -> ExceptT ErrorMessage Aff Unit
installBin version = do
  let binDir = "/usr/local/bin"
  tarPath <- downloadTar version
  extractedDir <- extractCljstyleTar tarPath binDir
  _ <- cacheDir { sourceDir: extractedDir, tool: "cljstyle", version: show version, arch: Nothing }
    # withExceptT (\_ -> ErrorMessage $ "Failed to extract " <> extractedDir)
  liftEffect $ addPath extractedDir
