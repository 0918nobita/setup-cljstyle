module Test.Installer where

import Prelude

import Control.Monad.Reader (ReaderT)
import Node.Path (FilePath)
import SetupCljstyle.Installer (class HasInstaller)
import Types (AffWithExcept, Version)

newtype TestInstaller = TestInstaller
  { run :: ReaderT Version AffWithExcept FilePath
  }

instance HasInstaller TestInstaller where
  runInstaller (TestInstaller { run }) = run

testInstaller :: TestInstaller
testInstaller = TestInstaller { run: pure "/home/user/.local/bin" }
