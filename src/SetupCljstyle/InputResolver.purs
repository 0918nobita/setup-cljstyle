module SetupCljstyle.InputResolver
  ( RunCheckInput(..)
  , resolveInputs
  ) where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Except (except, throwError)
import Control.Monad.Reader (ReaderT, ask, withReaderT)
import Control.Monad.Trans.Class (lift)
import Data.Argonaut (class DecodeJson, decodeJson, jsonParser, (.:))
import Data.Argonaut.Decode.Decoders (decodeBoolean, decodeJObject)
import Data.Either (Either)
import Data.EitherR (fmapL)
import Data.String (null)
import Data.String.Regex (Regex, test, regex)
import Data.String.Regex.Flags (noFlags)
import Effect.Class.Console (log)
import Fetcher (class Fetcher)
import GitHub.RestApi.Releases (fetchLatestRelease)
import SetupCljstyle.RawInputSource (RawInputs)
import Types (AffWithExcept, SingleError(..), Version(..))

type Env f =
  { fetcher :: f
  , rawInputs :: RawInputs
  }

versionRegex :: Either (SingleError String) Regex
versionRegex =
  regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags
    # fmapL SingleError

tryGetSpecifiedVersion :: forall f. ReaderT (Env f) AffWithExcept Version
tryGetSpecifiedVersion = do
  { rawInputs: { cljstyleVersion: version } } <- ask

  lift
    if null version then
      throwError $ SingleError "Version is not specified"
    else do
      verRegex <- except versionRegex

      if test verRegex version then
        pure $ Version version
      else
        throwError $ SingleError "The format of cljstyle-version is invalid."

tryGetLatestVersion :: forall f. Fetcher f => ReaderT (Env f) AffWithExcept Version
tryGetLatestVersion = do
  { fetcher, rawInputs: { authToken } } <- ask

  log "Attempt to fetch the latest version of cljstyle by calling GitHub REST API"
  lift $ fetchLatestRelease fetcher { authToken, owner: "greglook", repo: "cljstyle" }

resolveCljstyleVersionInput :: forall f. Fetcher f => ReaderT (Env f) AffWithExcept Version
resolveCljstyleVersionInput = tryGetSpecifiedVersion <|> tryGetLatestVersion

data RunCheckInput
  = RunCheck Boolean
  | DontRunCheck

instance Eq RunCheckInput where
  eq (RunCheck m1) (RunCheck m2) = m1 == m2
  eq DontRunCheck DontRunCheck = true
  eq _ _ = false

instance Show RunCheckInput where
  show (RunCheck true) = "RunCheck(reviewdog integration enabled)"
  show (RunCheck false) = "RunCheck(reviewdog integration disabled)"
  show (DontRunCheck) = "DontRunCheck"

instance DecodeJson RunCheckInput where
  decodeJson json = booleanFormat json <|> objectFormat json
    where
    booleanFormat j = do
      bool <- decodeBoolean j
      pure if bool then RunCheck false else DontRunCheck

    objectFormat j = do
      obj <- decodeJObject j
      reviewdogEnabled :: Boolean <- obj .: "reviewdog-enabled"
      pure $ RunCheck reviewdogEnabled

resolveRunCheckInput :: ReaderT RawInputs AffWithExcept RunCheckInput
resolveRunCheckInput = do
  { runCheck } <- ask

  lift do
    parsed <- except $ jsonParser runCheck # fmapL \_ -> SingleError "Failed to parse `run-check` input"

    except $ decodeJson parsed # fmapL \_ -> SingleError "The format of `run-check` input is invalid."

type Inputs =
  { cljstyleVersion :: Version
  , runCheck :: RunCheckInput
  }

resolveInputs :: forall f. Fetcher f => ReaderT (Env f) AffWithExcept Inputs
resolveInputs = do
  cljstyleVersion <- resolveCljstyleVersionInput
  runCheck <- withReaderT _.rawInputs resolveRunCheckInput
  pure { cljstyleVersion, runCheck }
