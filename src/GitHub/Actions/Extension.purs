module GitHub.Actions.Extension where

import Prelude

import Control.Monad.Except (ExceptT, mapExceptT, throwError)
import Control.Monad.Reader (ReaderT, mapReaderT)
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), Replacement(..), replaceAll, toUpper)
import Effect.Aff (Aff)
import GitHub.Actions.Core as Core
import Node.Process (lookupEnv)
import Types (EffectWithExcept, SingleError(..))

inputExceptT :: String -> EffectWithExcept String
inputExceptT name = do
  valOpt <- lift $ lookupEnv $ "INPUT_" <> toUpper (replaceAll (Pattern " ") (Replacement "_") name)
  case valOpt of
    Just val -> pure val
    Nothing -> throwError $ SingleError $ "Failed to get `" <> name <> "` input"

group :: forall a. String -> Aff a -> Aff a
group name aff = Core.group { name, fn: aff }

group' :: forall r e a. String -> ReaderT r (ExceptT e Aff) a -> ReaderT r (ExceptT e Aff) a
group' = mapReaderT <<< mapExceptT <<< group
