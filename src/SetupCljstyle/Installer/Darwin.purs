module SetupCljstyle.Installer.Darwin
  ( installBin
  ) where

import Control.Monad.Except (ExceptT, withExceptT)
import Control.Monad.Reader (ReaderT, ask, asks)
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class.Console (log)
import GitHub.Actions.ToolCache (cacheDir, downloadTool, extractTar)
import Milkis (URL(..))
import Node.Path (FilePath)
import Prelude
import SetupCljstyle.Types (SingleError(..), Version(..))

downloadUrl :: Version -> URL
downloadUrl (Version version) =
  URL $ "http://github.com/greglook/cljstyle/releases/download/"
    <> version
    <> "/cljstyle_"
    <> version
    <> "_macos.tar.gz"

downloadTar :: ReaderT Version (ExceptT (SingleError String) Aff) FilePath
downloadTar = do
  URL url <- asks downloadUrl
  lift do
    log $ "⬇️ Downloading " <> url
    downloadTool { url, auth: Nothing, dest: Nothing }
      # withExceptT \_ -> SingleError $ "Failed to download " <> url

extractCljstyleTar :: { tarPath :: FilePath, binDir :: FilePath } -> ExceptT (SingleError String) Aff FilePath
extractCljstyleTar { tarPath, binDir } = do
  log $ "🗃️ Extracting " <> tarPath <> " to " <> binDir
  extractTar { file: tarPath, dest: Just binDir, flags: Nothing }
    # withExceptT \_ -> SingleError $ "Failed to extract " <> tarPath

installBin :: ReaderT Version (ExceptT (SingleError String) Aff) FilePath
installBin = do
  let binDir = "/usr/local/bin"
  tarPath <- downloadTar

  extractedDir <- lift $ extractCljstyleTar { tarPath, binDir }

  Version version <- ask

  lift do
    log $ "📋 Caching " <> extractedDir
    _ <- cacheDir { sourceDir: extractedDir, tool: "cljstyle", version, arch: Nothing }
      # withExceptT \_ -> SingleError $ "Failed to extract " <> extractedDir

    pure extractedDir
