module SetupCljstyle.Cache where

import Control.Monad.Except (ExceptT, mapExceptT, throwError, withExceptT)
import Control.Monad.Reader (ReaderT, asks)
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import GitHub.Actions.ToolCache (find)
import Node.Path (FilePath)
import Prelude
import SetupCljstyle.Types (SingleError(..), Version)

cache :: ReaderT Version (ExceptT (SingleError String) Aff) FilePath
cache = do
  versionSpec <- asks show

  lift $ mapExceptT liftEffect do
    cachePath <- find { toolName: "cljstyle", versionSpec, arch: Nothing }
      # withExceptT \_ -> SingleError "Cache not found"
    case cachePath of
      Just p -> pure p
      Nothing -> throwError $ SingleError "Failed to get cache path"
