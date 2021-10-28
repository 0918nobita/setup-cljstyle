module SetupCljstyle.Installer where

import Prelude
import Effect (Effect)
import Node.Platform (Platform(Win32, Darwin))
import SetupCljstyle.Installer.Win32 as Win32
import SetupCljstyle.Installer.Darwin as Darwin
import SetupCljstyle.Installer.Linux as Linux
import SetupCljstyle.Types (Version)

installBin :: Platform -> Version -> Effect Unit
installBin Win32 = Win32.installBin

installBin Darwin = Darwin.installBin

installBin _ = Linux.installBin
