module SetupCljstyle.Inputs
  ( Inputs
  , gatherInputs
  ) where

import Control.Alt ((<|>))
import Control.Monad.Except (ExceptT, except, mapExceptT, throwError, withExceptT)
import Data.Argonaut (jsonParser)
import Data.Argonaut.Decode.Decoders (decodeBoolean)
import Data.Either (Either)
import Data.EitherR (fmapL)
import Data.Maybe (Maybe(Nothing))
import Data.String (null)
import Data.String.Regex (Regex, regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import GitHub.Actions.Core (getInput)
import GitHub.RestApi.Releases (fetchLatestRelease)
import Prelude
import SetupCljstyle.Types (SingleError(..), Version(..))

inputExceptT :: String -> ExceptT (SingleError String) Effect String
inputExceptT name =
  getInput { name, options: Nothing }
    # withExceptT \_ -> SingleError $ "Failed to get `" <> name <> "` input"

versionRegex :: Either (SingleError String) Regex
versionRegex = regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags # fmapL SingleError

specifiedVersion :: ExceptT (SingleError String) Aff Version
specifiedVersion = do
  version <- mapExceptT liftEffect $ inputExceptT "cljstyle-version"
  if null version then
    throwError $ SingleError "Version is not specified"
  else do
    verRegex <- except versionRegex
    if test verRegex version then
      pure $ Version version
    else
      throwError $ SingleError "The format of cljstyle-version is invalid."

latestVersion :: ExceptT (SingleError String) Aff Version
latestVersion = do
  log "Attempt to fetch the latest version of cljstyle by calling GitHub REST API"
  authToken <- mapExceptT liftEffect $ inputExceptT "token"
  fetchLatestRelease { authToken, owner: "greglook", repo: "cljstyle" }

type Inputs =
  { cljstyleVersion :: Version
  , authToken :: String
  , runCheck :: Boolean
  }

gatherInputs :: ExceptT (SingleError String) Aff Inputs
gatherInputs = do
  cljstyleVersion <- specifiedVersion <|> latestVersion

  mapExceptT liftEffect do
    authToken <- inputExceptT "token"

    runCheckRawStr <- inputExceptT "run-check"
    parsed <- except $ jsonParser runCheckRawStr # fmapL \_ -> SingleError "Failed to parse `run-check` input"
    runCheck <- except $ decodeBoolean parsed # fmapL \_ -> SingleError "The format of `run-check` input is invalid."

    pure { cljstyleVersion, authToken, runCheck }
