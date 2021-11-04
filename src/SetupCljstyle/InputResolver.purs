module SetupCljstyle.InputResolver where

import Control.Alt ((<|>))
import Control.Monad.Except (except, throwError)
import Control.Monad.Reader (ReaderT, ask)
import Control.Monad.Trans.Class (lift)
import Data.Argonaut (jsonParser)
import Data.Argonaut.Decode.Decoders (decodeBoolean)
import Data.Either (Either)
import Data.EitherR (fmapL)
import Data.String (null)
import Data.String.Regex (Regex, test, regex)
import Data.String.Regex.Flags (noFlags)
import Effect.Class.Console (log)
import GitHub.RestApi.Releases (fetchLatestRelease)
import Prelude
import Types (AffWithExcept, SingleError(..), Version(..))

type RawInputs =
  { cljstyleVersion :: String
  , authToken :: String
  , runCheck :: String
  }

-- TODO: make these methods lenses
class HasRawInputs a where
  getCljstyleVersion :: a -> AffWithExcept String
  getAuthToken :: a -> AffWithExcept String
  getRunCheck :: a -> AffWithExcept String

versionRegex :: Either (SingleError String) Regex
versionRegex = regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags # fmapL SingleError

tryGetSpecifiedVersion :: forall a. (HasRawInputs a) => ReaderT a AffWithExcept Version
tryGetSpecifiedVersion = do
  hasRawInputs <- ask
  lift do
    version <- getCljstyleVersion hasRawInputs
    if null version then
      throwError $ SingleError "Version is not specified"
    else do
      verRegex <- except versionRegex
      if test verRegex version then
        pure $ Version version
      else
        throwError $ SingleError "The format of cljstyle-version is invalid."

tryGetLatestVersion :: forall a. (HasRawInputs a) => ReaderT a AffWithExcept Version
tryGetLatestVersion = do
  hasRawInputs <- ask
  log "Attempt to fetch the latest version of cljstyle by calling GitHub REST API"
  lift do
    authToken <- getAuthToken hasRawInputs
    fetchLatestRelease { authToken, owner: "greglook", repo: "cljstyle" }

resolveCljstyleVersionInput :: forall a. (HasRawInputs a) => ReaderT a AffWithExcept Version
resolveCljstyleVersionInput = tryGetSpecifiedVersion <|> tryGetLatestVersion

resolveRunCheckInput :: forall a. (HasRawInputs a) => ReaderT a AffWithExcept Boolean
resolveRunCheckInput = do
  hasRawInputs <- ask
  lift do
    runCheck <- getRunCheck hasRawInputs

    parsed <- except $ jsonParser runCheck # fmapL \_ -> SingleError "Failed to parse `run-check` input"

    except $ decodeBoolean parsed # fmapL \_ -> SingleError "The format of `run-check` input is invalid."

type Inputs =
  { cljstyleVersion :: Version
  , runCheck :: Boolean
  }

resolveInputs :: forall a. (HasRawInputs a) => ReaderT a AffWithExcept Inputs
resolveInputs = do
  cljstyleVersion <- resolveCljstyleVersionInput

  runCheck <- resolveRunCheckInput

  pure { cljstyleVersion, runCheck }
