module SetupCljstyle.Installer.Win32
  ( installBin
  ) where

import Control.Monad.Trans.Class (lift)
import Control.Monad.Except (ExceptT, withExceptT)
import Control.Monad.Reader (ReaderT, ask, asks)
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
import SetupCljstyle.Types (SingleError(..), Version(..))

downloadUrl :: Version -> URL
downloadUrl (Version version) =
  URL $ "http://github.com/greglook/cljstyle/releases/download/"
    <> version
    <> "/cljstyle-"
    <> version
    <> ".jar"

binDir :: String
binDir = "D:\\cljstyle"

downloadJar :: ReaderT Version (ExceptT (SingleError String) Aff) Unit
downloadJar = do
  URL url <- asks downloadUrl
  version <- ask
  lift do
    log $ "⬇️ Downloading " <> url
    void $
      downloadTool
        { url
        , auth: Nothing
        , dest: Just $ concat [ binDir, "cljstyle-" <> show version <> ".jar" ]
        }
        # withExceptT \_ -> SingleError $ "Failed to download " <> url

installBin :: ReaderT Version (ExceptT (SingleError String) Aff) FilePath
installBin = do
  downloadJar

  version <- ask

  lift do
    let batchFilePath = concat [ binDir, "cljstyle.bat" ]
    log $ "📝 Write " <> batchFilePath
    let batchFileContent = "java -jar %~dp0cljstyle-" <> show version <> ".jar %*"
    (liftEffect $ writeTextFile UTF8 batchFilePath batchFileContent)
      # withExceptT \_ -> SingleError $ "Failed to write " <> batchFilePath

    log $ "📋 Caching " <> binDir
    _ <- cacheDir { sourceDir: binDir, tool: "cljstyle", version: show version, arch: Nothing }
      # withExceptT \_ -> SingleError $ "Failed to cache " <> binDir

    pure binDir
