module GitHub.Actions.Extension where

import Prelude

import Control.Monad.Except (throwError)
import Data.Maybe (Maybe(..))
import Data.String (Pattern(..), Replacement(..), replaceAll, toUpper, trim)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Sync (appendTextFile)
import Node.Process (lookupEnv)
import Types (SingleError(..), AffWithExcept)

addPath :: String -> AffWithExcept Unit
addPath path = do
  filePathOpt <- liftEffect $ lookupEnv "GITHUB_PATH"

  case filePathOpt of
    Just filePath ->
      liftEffect $ appendTextFile UTF8 filePath path
    Nothing -> throwError $ SingleError $ "The GITHUB_PATH environment variable not set"

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
