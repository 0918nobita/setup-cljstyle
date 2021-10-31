module SetupCljstyle.Installer where

import Control.Monad.Error.Class (throwError)
import Control.Monad.Except.Trans (ExceptT)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import Node.Path (FilePath)
import Node.Platform (Platform(Win32, Darwin))
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
      liftEffect $ log "🪟 Detected platform: Win32"
      Win32.installBin version
    Just Darwin -> do
      liftEffect $ log "🍎 Detected platform: Darwin"
      Darwin.installBin version
    Just _ -> do
      liftEffect $ log "🐧 Detected platform: Linux"
      Linux.installBin version
    Nothing -> throwError $ ErrorMessage "Failed to identify platform"
