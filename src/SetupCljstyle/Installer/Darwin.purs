module SetupCljstyle.Installer.Darwin
  ( installer
  ) where

import Prelude

import Control.Monad.Except (withExceptT)
import Control.Monad.Reader (ReaderT, ask, asks)
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(..))
import Effect.Class.Console (log)
import GitHub.Actions.ToolCache (cacheDir, downloadTool, extractTar)
import Node.Path (FilePath)
import SetupCljstyle.Installer (Installer(..))
import Types (AffWithExcept, SingleError(..), URL(..), Version(..))

downloadUrl :: Version -> URL
downloadUrl (Version version) =
  URL $ "http://github.com/greglook/cljstyle/releases/download/"
    <> version
    <> "/cljstyle_"
    <> version
    <> "_macos.tar.gz"

downloadTar :: ReaderT Version AffWithExcept FilePath
downloadTar = do
  URL url <- asks downloadUrl
  lift do
    log $ "Download " <> url
    downloadTool { url, auth: Nothing, dest: Nothing }
      # withExceptT \_ -> SingleError $ "Failed to download " <> url

extractCljstyleTar :: { tarPath :: FilePath, binDir :: FilePath } -> AffWithExcept FilePath
extractCljstyleTar { tarPath, binDir } = do
  log $ "Extract " <> tarPath <> " to " <> binDir
  extractTar { file: tarPath, dest: Just binDir, flags: Nothing }
    # withExceptT \_ -> SingleError $ "Failed to extract " <> tarPath

installer :: Installer
installer = Installer do
  let binDir = "/usr/local/bin"
  tarPath <- downloadTar

  Version version <- ask

  lift do
    extractedDir <- extractCljstyleTar { tarPath, binDir }
    log $ "Cache " <> extractedDir

    _ <- cacheDir { sourceDir: extractedDir, tool: "cljstyle", version, arch: Nothing }
      # withExceptT \_ -> SingleError $ "Failed to extract " <> extractedDir

    pure extractedDir
