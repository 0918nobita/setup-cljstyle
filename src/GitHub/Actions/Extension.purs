module GitHub.Actions.Extension where

import Prelude

import Control.Monad.Except (ExceptT, mapExceptT, withExceptT)
import Control.Monad.Reader (ReaderT, mapReaderT)
import Data.Maybe (Maybe(Nothing))
import Effect.Aff (Aff)
import GitHub.Actions.Core as Core
import Types (EffectWithExcept, SingleError(..))

inputExceptT :: String -> EffectWithExcept String
inputExceptT name =
  Core.getInput { name, options: Nothing }
    # withExceptT \_ -> SingleError $ "Failed to get `" <> name <> "` input"

group :: forall a. String -> Aff a -> Aff a
group name aff = Core.group { name, fn: aff }

group' :: forall r e a. String -> ReaderT r (ExceptT e Aff) a -> ReaderT r (ExceptT e Aff) a
group' = mapReaderT <<< mapExceptT <<< group
