module SetupCljstyle.Win32 where

import Prelude

import Control.Monad.Except (catchError)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error)
import GitHub.Actions.Core (addPath)
import GitHub.Actions.Io (mv)
import GitHub.Actions.ToolCache (cacheDir, downloadTool)
import Node.Encoding (Encoding(UTF8))
import Node.FS.Sync (writeTextFile)
import Node.Path (concat)
import Node.Process (exit)
import SetupCljstyle.Types (Version, Url)

downloadUrl :: Version -> Url
downloadUrl version =
  "http://github.com/greglook/cljstyle/releases/download/"
    <> version <> "/cljstyle-" <> version <> ".jar"

downloadJar :: Version -> Aff String
downloadJar version =
  let
    url = downloadUrl version
    tryDownloadJar = downloadTool url
  in
  catchError
    tryDownloadJar
    (\_ -> liftEffect do
      error $ "Failed to download " <> url
      exit 1)

installBin :: Version -> Effect Unit
installBin version =
  let binDir = "D:\\cljstyle" in
  launchAff_ do
    jarPath <- downloadJar version

    mv jarPath $ concat [binDir, "cljstyle-" <> version <> ".jar"]

    let batchFilePath = concat [binDir, "cljstyle.bat"]
    let batchFileContent = "java -jar %~dp0cljstyle-" <> version <> ".jar %*"
    liftEffect $ writeTextFile UTF8 batchFilePath batchFileContent

    _ <- cacheDir binDir "cljstyle" version

    liftEffect $ addPath binDir
