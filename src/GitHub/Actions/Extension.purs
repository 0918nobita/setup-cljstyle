module GitHub.Actions.Extension where

import Control.Monad.Except (ExceptT, mapExceptT, withExceptT)
import Data.Maybe (Maybe(Nothing))
import Effect.Aff (Aff)
import GitHub.Actions.Core as Core
import Prelude
import Types (EffectWithExcept, SingleError(..))

inputExceptT :: String -> EffectWithExcept String
inputExceptT name =
  Core.getInput { name, options: Nothing }
    # withExceptT \_ -> SingleError $ "Failed to get `" <> name <> "` input"

group :: forall a. String -> Aff a -> Aff a
group name aff = Core.group { name, fn: aff }

groupExceptT :: forall e a. String -> ExceptT e Aff a -> ExceptT e Aff a
groupExceptT = mapExceptT <<< group
