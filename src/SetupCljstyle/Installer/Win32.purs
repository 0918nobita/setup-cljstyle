module SetupCljstyle.Installer.Win32
  ( installBin
  ) where

import Control.Monad.Except.Trans (ExceptT, except, withExceptT)
import Data.Either (Either(Right))
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
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

binDir :: String
binDir = "D:\\cljstyle"

downloadJar :: Version -> ExceptT ErrorMessage Aff Unit
downloadJar version = do
  let
    URL url = downloadUrl version
    tryDownloadJar =
      downloadTool { url, auth: Nothing, dest: Just $ concat [ binDir, "cljstyle-" <> show version <> ".jar" ] }
        *> pure unit
  log $ "⬇️ Downloading " <> url
  tryDownloadJar # withExceptT (\_ -> ErrorMessage $ "Failed to download " <> url)

installBin :: Version -> ExceptT ErrorMessage Aff FilePath
installBin version = do
  downloadJar version

  let batchFilePath = concat [ binDir, "cljstyle.bat" ]
  log $ "📝 Write " <> batchFilePath
  let batchFileContent = "java -jar %~dp0cljstyle-" <> show version <> ".jar %*"
  (liftEffect $ writeTextFile UTF8 batchFilePath batchFileContent)
    # withExceptT (\_ -> ErrorMessage $ "Failed to write " <> batchFilePath)

  log $ "📋 Caching " <> binDir
  _ <- cacheDir { sourceDir: binDir, tool: "cljstyle", version: show version, arch: Nothing }
    # withExceptT (\_ -> ErrorMessage $ "Failed to cache " <> binDir)

  except $ Right binDir
