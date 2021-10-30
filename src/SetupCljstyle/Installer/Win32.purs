module SetupCljstyle.Installer.Win32 where

import Control.Monad.Except.Trans (ExceptT, withExceptT)
import Data.Maybe (Maybe(Nothing))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import GitHub.Actions.Core (addPath)
import GitHub.Actions.IO (mv)
import GitHub.Actions.ToolCache (cacheDir, downloadTool)
import Milkis (URL(..))
import Node.Encoding (Encoding(UTF8))
import Node.FS.Sync (writeTextFile)
import Node.Path (concat)
import Prelude
import SetupCljstyle.Types (ErrorMessage(..), Version(..))

downloadUrl :: Version -> URL
downloadUrl (Version version) =
  URL $ "http://github.com/greglook/cljstyle/releases/download/"
    <> version
    <> "/cljstyle-"
    <> version
    <> ".jar"

downloadJar :: Version -> ExceptT ErrorMessage Aff String
downloadJar version =
  let
    URL url = downloadUrl version
    tryDownloadJar = downloadTool { url, auth: Nothing, dest: Nothing }
  in
    tryDownloadJar # withExceptT (\_ -> ErrorMessage $ "Failed to download " <> url)

installBin :: Version -> ExceptT ErrorMessage Aff Unit
installBin version = do
  let binDir = "D:\\cljstyle"
  jarPath <- downloadJar version

  mv { source: jarPath, dest: concat [ binDir, "cljstyle-" <> show version <> ".jar" ], options: Nothing }
    # withExceptT (\_ -> ErrorMessage $ "Failed to move `cljstyle.jar` to " <> binDir)

  let batchFilePath = concat [ binDir, "cljstyle.bat" ]
  let batchFileContent = "java -jar %~dp0cljstyle-" <> show version <> ".jar %*"
  (liftEffect $ writeTextFile UTF8 batchFilePath batchFileContent)
    # withExceptT (\_ -> ErrorMessage $ "Failed to write " <> batchFilePath)

  _ <- cacheDir { sourceDir: binDir, tool: "cljstyle", version: show version, arch: Nothing }
    # withExceptT (\_ -> ErrorMessage $ "Failed to cache " <> binDir)

  liftEffect $ addPath binDir
