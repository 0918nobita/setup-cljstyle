module SetupCljstyle.Installer where

import Control.Monad.Error.Class (throwError)
import Control.Monad.Except.Trans (ExceptT)
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
import SetupCljstyle.Types (ErrorMessage(..), Version)

tryInstallBin :: Version -> ExceptT ErrorMessage Aff FilePath
tryInstallBin version =
  case Process.platform of
    Just Win32 -> do
      log "🪟 Detected platform: Win32"
      Win32.installBin version
    Just Darwin -> do
      log "🍎 Detected platform: Darwin"
      Darwin.installBin version
    Just Linux -> do
      log "🐧 Detected platform: Linux"
      Linux.installBin version
    Just _ -> throwError $ ErrorMessage "Unsupported platform"
    Nothing -> throwError $ ErrorMessage "Failed to identify platform"
