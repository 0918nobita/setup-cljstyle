module SetupCljstyle.Installer.Linux
  ( installBin
  ) where

import Control.Monad.Except.Trans (ExceptT, except, withExceptT)
import Data.Either (Either(Right))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import GitHub.Actions.IO (mkdirP)
import GitHub.Actions.ToolCache (cacheDir, downloadTool, extractTar)
import Milkis (URL(..))
import Node.Path (FilePath)
import Prelude
import SetupCljstyle.Types (ErrorMessage(..), Version(..))

downloadUrl :: Version -> URL
downloadUrl (Version version) =
  URL $ "http://github.com/greglook/cljstyle/releases/download/"
    <> version
    <> "/cljstyle_"
    <> version
    <> "_linux.tar.gz"

downloadTar :: Version -> ExceptT ErrorMessage Aff FilePath
downloadTar version =
  let
    URL url = downloadUrl version
    tryDownloadTar = downloadTool { url, auth: Nothing, dest: Nothing }
  in
    do
      liftEffect $ log $ "⬇️ Downloading " <> url
      tryDownloadTar # withExceptT (\_ -> ErrorMessage $ "Failed to download " <> url)

extractCljstyleTar :: String -> String -> ExceptT ErrorMessage Aff String
extractCljstyleTar tarPath binDir = do
  liftEffect $ log $ "🗃️ Extracting " <> tarPath <> " to " <> binDir
  extractTar { file: tarPath, dest: Just binDir, flags: Nothing }
    # withExceptT (\_ -> ErrorMessage $ "Failed to extract " <> tarPath)

installBin :: Version -> ExceptT ErrorMessage Aff FilePath
installBin version = do
  let binDir = "/home/runner/.local/bin"
  mkdirP { fsPath: binDir } # withExceptT (\_ -> ErrorMessage "Failed to make `~/.local/bin` directory")

  tarPath <- downloadTar version

  extractedDir <- extractCljstyleTar tarPath binDir

  liftEffect $ log $ "📋 Caching " <> extractedDir
  _ <- cacheDir { sourceDir: extractedDir, tool: "cljstyle", version: show version, arch: Nothing }
    # withExceptT (\_ -> ErrorMessage $ "Failed to cache " <> extractedDir)

  except $ Right extractedDir
