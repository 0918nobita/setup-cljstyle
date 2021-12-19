module SetupCljstyle.InputResolver
  ( DiffReportConfig(..)
  , RunCheckInput(..)
  , resolveInputs
  ) where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Except (except, mapExceptT, throwError, withExceptT)
import Control.Monad.Reader (ReaderT, ask, withReaderT)
import Control.Monad.Trans.Class (lift)
import Data.Argonaut (class DecodeJson, decodeJson, (.:))
import Data.Argonaut.Decode.Decoders (decodeBoolean, decodeJObject)
import Data.Either (Either)
import Data.EitherR (fmapL)
import Data.Identity (Identity(..))
import Data.String (null)
import Data.String.Regex (Regex, test, regex)
import Data.String.Regex.Flags (noFlags)
import Data.YAML.Foreign.Decode (parseYAMLToJson)
import Effect.Class.Console (log)
import Fetcher (TextFetcher)
import GitHub.RestApi.Releases (fetchLatestRelease)
import SetupCljstyle.RawInputSource (RawInputs)
import Types (AffWithExcept, SingleError(..), Version(..))

type Env =
  { fetcher :: TextFetcher
  , rawInputs :: RawInputs
  }

versionRegex :: Either (SingleError String) Regex
versionRegex =
  regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags
    # fmapL SingleError

tryGetSpecifiedVersion :: ReaderT Env AffWithExcept Version
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

tryGetLatestVersion :: ReaderT Env AffWithExcept Version
tryGetLatestVersion = do
  { fetcher, rawInputs: { authToken } } <- ask

  log "Attempt to fetch the latest version of cljstyle by calling GitHub REST API"
  lift $ fetchLatestRelease fetcher { authToken, owner: "greglook", repo: "cljstyle" }

resolveCljstyleVersionInput :: ReaderT Env AffWithExcept Version
resolveCljstyleVersionInput = tryGetSpecifiedVersion <|> tryGetLatestVersion

data DiffReportConfig
  = DiffReportEnabled
  | DiffReportDisabled

instance Eq DiffReportConfig where
  eq DiffReportEnabled DiffReportEnabled = true
  eq DiffReportDisabled DiffReportDisabled = true
  eq _ _ = false

data RunCheckInput
  = RunCheck DiffReportConfig
  | DontRunCheck

instance Eq RunCheckInput where
  eq (RunCheck m1) (RunCheck m2) = m1 == m2
  eq DontRunCheck DontRunCheck = true
  eq _ _ = false

instance Show RunCheckInput where
  show (RunCheck DiffReportEnabled) = "RunCheck(reviewdog integration enabled)"
  show (RunCheck DiffReportDisabled) = "RunCheck(reviewdog integration disabled)"
  show (DontRunCheck) = "DontRunCheck"

instance DecodeJson RunCheckInput where
  decodeJson json = booleanFormat json <|> objectFormat json
    where
    booleanFormat j = do
      bool <- decodeBoolean j
      pure if bool then RunCheck DiffReportDisabled else DontRunCheck

    objectFormat j = do
      obj <- decodeJObject j
      diffReportEnabled :: Boolean <- obj .: "diff-report"
      pure $ RunCheck if diffReportEnabled then DiffReportEnabled else DiffReportDisabled

resolveRunCheckInput :: ReaderT RawInputs AffWithExcept RunCheckInput
resolveRunCheckInput = do
  { runCheck } <- ask

  lift do
    parsed <-
      parseYAMLToJson runCheck
        # withExceptT (\_ -> SingleError "Failed to parse `run-check` input as YAML string")
        # mapExceptT \(Identity a) -> pure a

    except $ decodeJson parsed # fmapL \_ -> SingleError "The format of `run-check` input is invalid."

type Inputs =
  { cljstyleVersion :: Version
  , runCheck :: RunCheckInput
  }

resolveInputs :: ReaderT Env AffWithExcept Inputs
resolveInputs = do
  cljstyleVersion <- resolveCljstyleVersionInput
  runCheck <- withReaderT _.rawInputs resolveRunCheckInput
  pure { cljstyleVersion, runCheck }
