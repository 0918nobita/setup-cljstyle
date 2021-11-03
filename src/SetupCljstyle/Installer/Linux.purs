module SetupCljstyle.Installer.Linux
  ( InstallerForLinux
  , installer
  ) where

import Control.Monad.Except (ExceptT, withExceptT)
import Control.Monad.Reader (ReaderT, ask, asks)
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class.Console (log)
import GitHub.Actions.IO (mkdirP)
import GitHub.Actions.ToolCache (cacheDir, downloadTool, extractTar)
import Milkis (URL(..))
import Node.Path (FilePath)
import Prelude
import SetupCljstyle.Installer (class HasInstaller)
import SetupCljstyle.Types (SingleError(..), Version(..))

downloadUrl :: Version -> URL
downloadUrl (Version version) =
  URL $ "http://github.com/greglook/cljstyle/releases/download/"
    <> version
    <> "/cljstyle_"
    <> version
    <> "_linux.tar.gz"

downloadTar :: ReaderT Version (ExceptT (SingleError String) Aff) FilePath
downloadTar = do
  URL url <- asks downloadUrl
  lift do
    log $ "⬇️ Download " <> url
    downloadTool { url, auth: Nothing, dest: Nothing }
      # withExceptT \_ -> SingleError $ "Failed to download " <> url

extractCljstyleTar :: { tarPath :: FilePath, binDir :: FilePath } -> ExceptT (SingleError String) Aff FilePath
extractCljstyleTar { tarPath, binDir } = do
  log $ "🗃️ Extract " <> tarPath <> " to " <> binDir
  extractTar { file: tarPath, dest: Just binDir, flags: Nothing }
    # withExceptT \_ -> SingleError $ "Failed to extract " <> tarPath

installBin :: ReaderT Version (ExceptT (SingleError String) Aff) FilePath
installBin = do
  let binDir = "/home/runner/.local/bin"
  lift $ mkdirP { fsPath: binDir } # withExceptT \_ -> SingleError "Failed to make `~/.local/bin` directory"

  tarPath <- downloadTar

  extractedDir <- lift $ extractCljstyleTar { tarPath, binDir }

  version <- ask

  lift do
    log $ "📋 Cache " <> extractedDir
    _ <- cacheDir { sourceDir: extractedDir, tool: "cljstyle", version: show version, arch: Nothing }
      # withExceptT \_ -> SingleError $ "Failed to cache " <> extractedDir

    pure extractedDir

newtype InstallerForLinux = InstallerForLinux
  { run :: ReaderT Version (ExceptT (SingleError String) Aff) FilePath
  }

instance HasInstaller InstallerForLinux where
  runInstaller (InstallerForLinux { run }) = run

installer :: InstallerForLinux
installer = InstallerForLinux { run: installBin }
