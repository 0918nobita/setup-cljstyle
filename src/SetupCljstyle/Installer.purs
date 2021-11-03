module SetupCljstyle.Installer where

import Control.Monad.Except (ExceptT)
import Control.Monad.Reader (ReaderT)
import Effect.Aff (Aff)
import Node.Path (FilePath)
import SetupCljstyle.Types (SingleError, Version)

-- | For dependency injection
class HasInstaller a where
  runInstaller :: a -> ReaderT Version (ExceptT (SingleError String) Aff) FilePath
