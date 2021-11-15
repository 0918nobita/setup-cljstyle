module GitHub.Actions.Extension where

import Prelude

import Control.Monad.Except (throwError)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), Replacement(..), replaceAll, toUpper, trim)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Process (lookupEnv)
import Types (SingleError(..), AffWithExcept)

getInput :: String -> AffWithExcept String
getInput name = do
  valOpt <-
    liftEffect
      $ map (map trim)
      $ lookupEnv
      $ "INPUT_" <> toUpper (replaceAll (Pattern " ") (Replacement "_") name)
  case valOpt of
    Just val ->
      pure val
    Nothing ->
      throwError $ SingleError $ "Failed to get `" <> name <> "` input"

group :: forall a. String -> AffWithExcept a -> AffWithExcept a
group name fn = do
  log $ "::group::" <> name
  res <- fn
  log "::endgroup::"
  pure res
