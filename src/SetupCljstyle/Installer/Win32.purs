module SetupCljstyle.Installer.Win32 where

import Prelude
import Control.Monad.Except (catchError)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error)
import GitHub.Actions.Core (addPath)
import GitHub.Actions.Io (mv)
import GitHub.Actions.ToolCache (cacheDir, downloadTool)
import Milkis (URL(..))
import Node.Encoding (Encoding(UTF8))
import Node.FS.Sync (writeTextFile)
import Node.Path (concat)
import Node.Process (exit)
import SetupCljstyle.Types (Version(..))

downloadUrl :: Version -> URL
downloadUrl (Version version) =
  URL $ "http://github.com/greglook/cljstyle/releases/download/"
    <> version
    <> "/cljstyle-"
    <> version
    <> ".jar"

downloadJar :: Version -> Aff String
downloadJar version =
  let
    url = downloadUrl version
    tryDownloadJar = downloadTool url
  in
    catchError
      tryDownloadJar
      ( \_ ->
          liftEffect do
            error $ "Failed to download " <> show url
            exit 1
      )

installBin :: Version -> Effect Unit
installBin version =
  launchAff_ do
    let binDir = "D:\\cljstyle"
    jarPath <- downloadJar version

    mv jarPath $ concat [ binDir, "cljstyle-" <> show version <> ".jar" ]

    let batchFilePath = concat [ binDir, "cljstyle.bat" ]
    let batchFileContent = "java -jar %~dp0cljstyle-" <> show version <> ".jar %*"
    liftEffect $ writeTextFile UTF8 batchFilePath batchFileContent

    _ <- cacheDir binDir "cljstyle" version

    liftEffect $ addPath binDir
