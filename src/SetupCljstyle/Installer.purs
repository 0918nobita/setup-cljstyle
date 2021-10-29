module SetupCljstyle.Installer where

import Control.Monad.Except.Trans (ExceptT)
import Effect.Aff (Aff)
import Node.Platform (Platform(Win32, Darwin))
import Prelude
import SetupCljstyle.Installer.Win32 as Win32
import SetupCljstyle.Installer.Darwin as Darwin
import SetupCljstyle.Installer.Linux as Linux
import SetupCljstyle.Types (ErrorMessage, Version)

installBin :: Platform -> Version -> ExceptT ErrorMessage Aff Unit
installBin Win32 = Win32.installBin
installBin Darwin = Darwin.installBin
installBin _ = Linux.installBin
