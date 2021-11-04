module SetupCljstyle.Installer.Linux
  ( InstallerForLinux
  , installer
  ) where

import Control.Monad.Except (withExceptT)
import Control.Monad.Reader (ReaderT, ask, asks)
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(..))
import Effect.Class.Console (log)
import GitHub.Actions.IO (mkdirP)
import GitHub.Actions.ToolCache (cacheDir, downloadTool, extractTar)
import Milkis (URL(..))
import Node.Path (FilePath)
import Prelude
import SetupCljstyle.Installer (class HasInstaller)
import Types (AffWithExcept, SingleError(..), Version(..))

binDir :: String
binDir = "/home/runner/.local/bin"

downloadUrl :: Version -> URL
downloadUrl (Version version) =
  URL $ "http://github.com/greglook/cljstyle/releases/download/"
    <> version
    <> "/cljstyle_"
    <> version
    <> "_linux.tar.gz"

downloadTar :: ReaderT Version AffWithExcept FilePath
downloadTar = do
  URL url <- asks downloadUrl

  lift do
    mkdirP { fsPath: binDir } # withExceptT \_ -> SingleError "Failed to make `~/.local/bin` directory"
    log $ "Download " <> url
    downloadTool { url, auth: Nothing, dest: Nothing }
      # withExceptT \_ -> SingleError $ "Failed to download " <> url

extractCljstyleTar :: FilePath -> AffWithExcept FilePath
extractCljstyleTar tarPath = do
  log $ "Extract " <> tarPath <> " to " <> binDir
  extractTar { file: tarPath, dest: Just binDir, flags: Nothing }
    # withExceptT \_ -> SingleError $ "Failed to extract " <> tarPath

installBin :: ReaderT Version AffWithExcept FilePath
installBin = do
  tarPath <- downloadTar

  Version version <- ask

  lift do
    extractedDir <- extractCljstyleTar tarPath
    log $ "Cache " <> extractedDir

    _ <- cacheDir { sourceDir: extractedDir, tool: "cljstyle", version, arch: Nothing }
      # withExceptT \_ -> SingleError $ "Failed to cache " <> extractedDir

    pure extractedDir

newtype InstallerForLinux = InstallerForLinux
  { run :: ReaderT Version AffWithExcept FilePath
  }

instance HasInstaller InstallerForLinux where
  runInstaller (InstallerForLinux { run }) = run

installer :: InstallerForLinux
installer = InstallerForLinux { run: installBin }
