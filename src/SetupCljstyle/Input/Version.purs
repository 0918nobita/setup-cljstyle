module SetupCljstyle.Input.Version
  ( cljstyleVersionInput
  ) where

import Control.Alt ((<|>))
import Control.Monad.Except (except, mapExceptT, throwError)
import Data.Either (Either)
import Data.EitherR (fmapL)
import Data.String.Regex (Regex, regex, test)
import Data.String.Regex.Flags (noFlags)
import Data.String (null)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import GitHub.Actions.Extension (inputExceptT)
import GitHub.RestApi.Releases (fetchLatestRelease)
import Prelude
import Types (AffWithExcept, SingleError(..), Version(..))

versionRegex :: Either (SingleError String) Regex
versionRegex = regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags # fmapL SingleError

specifiedVersion :: AffWithExcept Version
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

latestVersion :: AffWithExcept Version
latestVersion = do
  log "Attempt to fetch the latest version of cljstyle by calling GitHub REST API"
  authToken <- mapExceptT liftEffect $ inputExceptT "token"
  fetchLatestRelease { authToken, owner: "greglook", repo: "cljstyle" }

cljstyleVersionInput :: AffWithExcept Version
cljstyleVersionInput = specifiedVersion <|> latestVersion
