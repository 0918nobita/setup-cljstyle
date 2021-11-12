module SetupCljstyle.InputResolver
  ( resolveInputs
  ) where

import Control.Alt ((<|>))
import Control.Monad.Except (except, throwError)
import Control.Monad.Reader (ReaderT, ask, runReaderT, withReaderT)
import Control.Monad.Trans.Class (lift)
import Data.Argonaut (jsonParser)
import Data.Argonaut.Decode.Decoders (decodeBoolean)
import Data.Either (Either)
import Data.EitherR (fmapL)
import Data.String (null)
import Data.String.Regex (Regex, test, regex)
import Data.String.Regex.Flags (noFlags)
import Effect.Class.Console (log)
import Fetcher (class Fetcher)
import GitHub.RestApi.Releases (fetchLatestRelease)
import Prelude
import SetupCljstyle.RawInputSource (RawInputs)
import Types (AffWithExcept, SingleError(..), Version(..))

type Env a =
  { fetcher :: a
  , rawInputs :: RawInputs
  }

versionRegex :: Either (SingleError String) Regex
versionRegex =
  regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags
    # fmapL SingleError

tryGetSpecifiedVersion :: forall a. ReaderT (Env a) AffWithExcept Version
tryGetSpecifiedVersion = do
  { rawInputs: { cljstyleVersion: version } } <- ask

  lift do
    if null version then
      throwError $ SingleError "Version is not specified"
    else do
      verRegex <- except versionRegex

      if test verRegex version then
        pure $ Version version
      else
        throwError $ SingleError "The format of cljstyle-version is invalid."

tryGetLatestVersion :: forall a. Fetcher a => ReaderT (Env a) AffWithExcept Version
tryGetLatestVersion = do
  { fetcher, rawInputs: { authToken } } <- ask

  log "Attempt to fetch the latest version of cljstyle by calling GitHub REST API"

  lift $ fetchLatestRelease fetcher { authToken, owner: "greglook", repo: "cljstyle" }

resolveCljstyleVersionInput :: forall a. Fetcher a => ReaderT (Env a) AffWithExcept Version
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

resolveInputs :: forall a. Fetcher a => Env a -> AffWithExcept Inputs
resolveInputs env = runReaderT reader env
  where
  reader = do
    cljstyleVersion <- resolveCljstyleVersionInput
    runCheck <- withReaderT _.rawInputs resolveRunCheckInput
    pure { cljstyleVersion, runCheck }
