module SetupCljstyle.Installer where

import Control.Monad.Reader (ReaderT)
import Node.Path (FilePath)
import Types (AffWithExcept, Version)

-- | For dependency injection
class HasInstaller a where
  runInstaller :: a -> ReaderT Version AffWithExcept FilePath
