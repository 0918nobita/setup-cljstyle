module Test.Installer where

import Prelude

import SetupCljstyle.Installer (Installer(..))

testInstaller :: Installer
testInstaller = Installer $ pure "/home/user/.local/bin"
