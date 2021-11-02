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
import Effect.Class.Console (errorShow, log, logShow)
import GitHub.Actions.Core (addPath, group)
import GitHub.Actions.ToolCache (find)
import GitHub.RestApi.Releases (fetchLatestRelease)
import Node.ChildProcess (defaultExecOptions, exec)
import Node.Path (FilePath)
import Node.Process (exit)
import Prelude
import SetupCljstyle.Inputs (authTokenInput, cljstyleVersionInput, runCheckInput)
import SetupCljstyle.Installer (tryInstallBin)
import SetupCljstyle.Types (ErrorMessage(..), Version(..))

versionRegex :: Either ErrorMessage Regex
versionRegex = regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags # fmapL ErrorMessage

tryGetSpecifiedVer :: ExceptT ErrorMessage Aff Version
tryGetSpecifiedVer = do
  log "Attempting to get specified version"
  version <- mapExceptT liftEffect cljstyleVersionInput
  log $ "Specificed version: " <> version
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
  log "Attempting to get the latest version"
  authToken <- mapExceptT liftEffect authTokenInput
  fetchLatestRelease { authToken, owner: "greglook", repo: "cljstyle" }

tryUseCache :: Version -> ExceptT ErrorMessage Aff FilePath
tryUseCache (Version version) =
  mapExceptT liftEffect do
    cachePath <- find { toolName: "cljstyle", versionSpec: version, arch: Nothing }
      # withExceptT (\_ -> ErrorMessage "Cache not found")
    case cachePath of
      Just p -> except $ Right p
      Nothing -> throwError $ ErrorMessage "Failed to get cache path"

group' :: forall e a. String -> ExceptT e Aff a -> ExceptT e Aff a
group' name = mapExceptT (\aff -> group { fn: aff, name })

mainAff :: ExceptT ErrorMessage Aff Unit
mainAff = do
  runCheck <- mapExceptT liftEffect runCheckInput

  version <- group' "🔖 Determining the version of cljstyle installed" do
    version <- tryGetSpecifiedVer <|> tryGetLatestVer
    log $ "Determined version: " <> show version
    pure version

  group' ("➕ Installing cljstyle " <> show version) do
    cachePath <- tryUseCache version <|> tryInstallBin version
    liftEffect $ addPath cachePath

  if runCheck then do
    _ <- group' "▶️ Run `cljstyle check`" $ liftEffect $ exec "cljstyle check" defaultExecOptions (\res -> logShow res.error)
    pure unit
  else mempty

handleError :: ErrorMessage -> ExceptT ErrorMessage Aff Unit
handleError msg = do
  errorShow msg
  liftEffect $ exit 1

main :: Effect Unit
main = launchAff_ $ runExceptT $ catchError mainAff handleError
