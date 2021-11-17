module SetupCljstyle.Installer where

import Control.Monad.Reader (ReaderT)
import Node.Path (FilePath)
import Types (AffWithExcept, Version)

newtype Installer = Installer (ReaderT Version AffWithExcept FilePath)

runInstaller :: Installer -> ReaderT Version AffWithExcept FilePath
runInstaller (Installer reader) = reader
