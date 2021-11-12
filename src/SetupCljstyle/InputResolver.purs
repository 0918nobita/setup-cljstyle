module SetupCljstyle.InputResolver where

import Control.Alt ((<|>))
import Control.Monad.Except (except, throwError)
import Control.Monad.Reader (ReaderT, ask, asks, runReaderT)
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
import SetupCljstyle.RawInputSource (RawInputs)
import Types (AffWithExcept, SingleError(..), Version(..))

versionRegex :: Either (SingleError String) Regex
versionRegex = regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags # fmapL SingleError

tryGetSpecifiedVersion :: ReaderT RawInputs AffWithExcept Version
tryGetSpecifiedVersion = do
  version <- asks _.cljstyleVersion
  lift do
    if null version then
      throwError $ SingleError "Version is not specified"
    else do
      verRegex <- except versionRegex
      if test verRegex version then
        pure $ Version version
      else
        throwError $ SingleError "The format of cljstyle-version is invalid."

tryGetLatestVersion :: ReaderT RawInputs AffWithExcept Version
tryGetLatestVersion = do
  { authToken } <- ask
  log "Attempt to fetch the latest version of cljstyle by calling GitHub REST API"
  lift do
    fetchLatestRelease { authToken, owner: "greglook", repo: "cljstyle" }

resolveCljstyleVersionInput :: ReaderT RawInputs AffWithExcept Version
resolveCljstyleVersionInput = tryGetSpecifiedVersion <|> tryGetLatestVersion

resolveRunCheckInput :: ReaderT RawInputs AffWithExcept Boolean
resolveRunCheckInput = do
  { runCheck } <- ask
  lift do
    parsed <- except $ jsonParser runCheck # fmapL \_ -> SingleError "Failed to parse `run-check` input"

    except $ decodeBoolean parsed # fmapL \_ -> SingleError "The format of `run-check` input is invalid."

type Inputs =
  { cljstyleVersion :: Version
  , runCheck :: Boolean
  }

resolveInputs :: RawInputs -> AffWithExcept Inputs
resolveInputs rawInputs = do
  runReaderT reader rawInputs
  where
  reader = do
    cljstyleVersion <- resolveCljstyleVersionInput
    runCheck <- resolveRunCheckInput
    pure { cljstyleVersion, runCheck }
