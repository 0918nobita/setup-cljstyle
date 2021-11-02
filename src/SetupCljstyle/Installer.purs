module SetupCljstyle.Installer where

import Control.Monad.Except (ExceptT, throwError)
import Control.Monad.Reader (ReaderT)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class.Console (log)
import Node.Path (FilePath)
import Node.Platform (Platform(Win32, Darwin, Linux))
import Node.Process as Process
import Prelude
import SetupCljstyle.Installer.Win32 as Win32
import SetupCljstyle.Installer.Darwin as Darwin
import SetupCljstyle.Installer.Linux as Linux
import SetupCljstyle.Types (SingleError(..), Version)

tryInstallBin :: ReaderT Version (ExceptT (SingleError String) Aff) FilePath
tryInstallBin =
  case Process.platform of
    Just Win32 -> do
      log "🪟 Detected platform: Win32"
      Win32.installBin
    Just Darwin -> do
      log "🍎 Detected platform: Darwin"
      Darwin.installBin
    Just Linux -> do
      log "🐧 Detected platform: Linux"
      Linux.installBin
    Just _ -> throwError $ SingleError "Unsupported platform"
    Nothing -> throwError $ SingleError "Failed to identify platform"
