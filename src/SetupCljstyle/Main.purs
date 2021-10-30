module SetupCljstyle.Main
  ( main
  ) where

import Control.Alt ((<|>))
import Control.Monad.Error.Class (throwError)
import Control.Monad.Except (ExceptT, catchError, except, mapExceptT, runExceptT, withExceptT)
import Data.Either (Either(..))
import Data.EitherR (fmapL)
import Data.Maybe (Maybe(..))
import Data.String (null)
import Data.String.Regex (Regex, regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error, log)
import GitHub.Actions.Core (addPath, getInput)
import GitHub.Actions.ToolCache (find)
import GitHub.RestApi.Releases (fetchLatestRelease)
import Node.Path (FilePath)
import Node.Process (exit)
import Prelude
import SetupCljstyle.Installer (tryInstallBin)
import SetupCljstyle.Types (ErrorMessage(..), Version(..))

getVerOption :: ExceptT ErrorMessage Effect String
getVerOption =
  getInput { name: "cljstyle-version", options: Nothing }
    # withExceptT (\_ -> ErrorMessage "Failed to get `cljstyle-version` input")

getAuthToken :: ExceptT ErrorMessage Effect String
getAuthToken =
  getInput { name: "token", options: Nothing }
    # withExceptT (\_ -> ErrorMessage "Failed to get `token` input")

versionRegex :: Either ErrorMessage Regex
versionRegex = regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags # fmapL ErrorMessage

tryGetSpecifiedVer :: ExceptT ErrorMessage Aff Version
tryGetSpecifiedVer = do
  liftEffect $ log "Attempting to get specified version"
  version <- mapExceptT liftEffect getVerOption
  liftEffect $ log $ "Specificed version: " <> version
  except
    if null version then
      Left $ ErrorMessage "Version is not specified"
    else do
      verRegex <- versionRegex
      if test verRegex version then
        Right $ Version version
      else
        Left $ ErrorMessage "The format of cljstyle-version is invalid."

tryGetLatestVer :: ExceptT ErrorMessage Aff Version
tryGetLatestVer = do
  liftEffect $ log "Attempting to get the latest version"
  authToken <- mapExceptT liftEffect getAuthToken
  fetchLatestRelease { authToken, owner: "greglook", repo: "cljstyle" }

tryUseCache :: Version -> ExceptT ErrorMessage Aff FilePath
tryUseCache (Version version) =
  mapExceptT liftEffect do
    cachePath <- find { toolName: "cljstyle", versionSpec: version, arch: Nothing }
      # withExceptT (\_ -> ErrorMessage "Cache not found")
    case cachePath of
      Just p -> except $ Right p
      Nothing -> throwError $ ErrorMessage "Failed to get cache path"

mainAff :: ExceptT ErrorMessage Aff Unit
mainAff = do
  liftEffect $ log "::group::🔖 Determining the version of cljstyle installed"
  version <- tryGetSpecifiedVer <|> tryGetLatestVer
  liftEffect do
    log $ "Determined version: " <> show version
    log "::endgroup::"
    log $ "::group::➕ Installing cljstyle " <> show version
  cachePath <- tryUseCache version <|> tryInstallBin version
  liftEffect $ addPath cachePath
  log "::endgroup::"

handleError :: ErrorMessage -> ExceptT ErrorMessage Aff Unit
handleError msg = liftEffect $ error (show msg) *> exit 1

main :: Effect Unit
main = launchAff_ $ runExceptT $ catchError mainAff handleError
