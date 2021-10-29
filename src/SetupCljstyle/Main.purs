module SetupCljstyle.Main
  ( main
  ) where

import Prelude
import Control.Alt ((<|>))
import Control.Monad.Except (ExceptT(..), catchError, except, mapExceptT, runExceptT, withExceptT)
import Control.Monad.Trans.Class (lift)
import Data.Either (Either(..))
import Data.EitherR (fmapL)
import Data.String (null)
import Data.String.Regex (Regex, regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error)
import GitHub.Actions.Core (addPath, getOptionalInput)
import GitHub.Actions.ToolCache (find)
import GitHub.RestApi.Releases (fetchLatestRelease)
import Node.Process (exit)
import Node.ProcessExt (platform)
import SetupCljstyle.Installer (installBin)
import SetupCljstyle.Types (ErrorMessage(..), Version(..))

getVerOption :: Effect String
getVerOption = getOptionalInput "cljstyle-version"

getAuthToken :: Effect String
getAuthToken = getOptionalInput "token"

versionRegex :: Either ErrorMessage Regex
versionRegex = regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags # fmapL ErrorMessage

tryGetSpecifiedVer :: ExceptT ErrorMessage Aff Version
tryGetSpecifiedVer =
  mapExceptT liftEffect $ ExceptT do
    version <- getVerOption
    pure
      if null version then
        Left $ ErrorMessage "Version is not specified"
      else do
        verRegex <- versionRegex
        if test verRegex version then
          Right $ Version version
        else
          Left $ ErrorMessage "The format of cljstyle-version is invalid."

tryGetLatestVer :: String -> ExceptT ErrorMessage Aff Version
tryGetLatestVer authToken = fetchLatestRelease { authToken, owner: "greglook", repo: "cljstyle" }

tryUseCache :: Version -> ExceptT ErrorMessage Aff Unit
tryUseCache version =
  mapExceptT liftEffect do
    cachePath <- find "cljstyle" version # withExceptT (\_ -> ErrorMessage "Cache not found")
    lift $ addPath cachePath

tryInstallBin :: Version -> ExceptT ErrorMessage Aff Unit
tryInstallBin version =
  mapExceptT liftEffect do
    p <- except platform # withExceptT (\_ -> ErrorMessage "Failed to identify platform")
    lift $ installBin p version

mainAff :: String -> ExceptT ErrorMessage Aff Unit
mainAff authToken = do
  version <- tryGetSpecifiedVer <|> (tryGetLatestVer authToken)
  tryUseCache version <|> tryInstallBin version

handleError :: ErrorMessage -> ExceptT ErrorMessage Aff Unit
handleError msg = liftEffect $ error (show msg) *> exit 1

main :: Effect Unit
main = do
  authToken <- getAuthToken
  launchAff_ $ runExceptT $ catchError (mainAff authToken) handleError
