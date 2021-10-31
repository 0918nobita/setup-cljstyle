module SetupCljstyle.Installer.Win32 where

import Control.Monad.Except.Trans (ExceptT, except, withExceptT)
import Data.Either (Either(Right))
import Data.Maybe (Maybe(Nothing))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import GitHub.Actions.IO (mv)
import GitHub.Actions.ToolCache (cacheDir, downloadTool)
import Milkis (URL(..))
import Node.Encoding (Encoding(UTF8))
import Node.FS.Sync (writeTextFile)
import Node.Path (FilePath, concat)
import Prelude
import SetupCljstyle.Types (ErrorMessage(..), Version(..))

downloadUrl :: Version -> URL
downloadUrl (Version version) =
  URL $ "http://github.com/greglook/cljstyle/releases/download/"
    <> version
    <> "/cljstyle-"
    <> version
    <> ".jar"

downloadJar :: Version -> ExceptT ErrorMessage Aff FilePath
downloadJar version =
  let
    URL url = downloadUrl version
    tryDownloadJar = downloadTool { url, auth: Nothing, dest: Nothing }
  in
    do
      liftEffect $ log $ "⬇️ Downloading " <> url
      tryDownloadJar # withExceptT (\_ -> ErrorMessage $ "Failed to download " <> url)

installBin :: Version -> ExceptT ErrorMessage Aff FilePath
installBin version = do
  let binDir = "D:\\cljstyle"
  jarPath <- downloadJar version

  let dest = concat [ binDir, "cljstyle-" <> show version <> ".jar" ]
  liftEffect $ log $ "🚚 Move " <> jarPath <> " to " <> dest
  mv { source: jarPath, dest, options: Nothing }
    # withExceptT (\_ -> ErrorMessage $ "Failed to move `cljstyle.jar` to " <> binDir)

  let batchFilePath = concat [ binDir, "cljstyle.bat" ]
  liftEffect $ log $ "📝 Write " <> batchFilePath
  let batchFileContent = "java -jar %~dp0cljstyle-" <> show version <> ".jar %*"
  (liftEffect $ writeTextFile UTF8 batchFilePath batchFileContent)
    # withExceptT (\_ -> ErrorMessage $ "Failed to write " <> batchFilePath)

  liftEffect $ log $ "📋 Caching " <> binDir
  _ <- cacheDir { sourceDir: binDir, tool: "cljstyle", version: show version, arch: Nothing }
    # withExceptT (\_ -> ErrorMessage $ "Failed to cache " <> binDir)

  except $ Right binDir
