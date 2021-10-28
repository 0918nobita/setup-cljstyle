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
versionRegex =
  regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags # fmapL ErrorMessage

specifiedVersion :: ExceptT ErrorMessage Aff Version
specifiedVersion = mapExceptT liftEffect $ ExceptT do
  version <- getVerOption

  pure if null version
    then Left $ ErrorMessage "Version is not specified"
    else do
      verRegex <- versionRegex

      if test verRegex version
        then Right $ Version version
        else Left $ ErrorMessage "The format of cljstyle-version is invalid."

usingCache :: Version -> ExceptT ErrorMessage Aff Unit
usingCache version = mapExceptT liftEffect do
  cachePath <- find "cljstyle" version # withExceptT (\_ -> ErrorMessage "Cache not found")
  lift $ addPath cachePath

newlyInstallBin :: Version -> ExceptT ErrorMessage Aff Unit
newlyInstallBin version = mapExceptT liftEffect do
  p <- except platform # withExceptT (\_ -> ErrorMessage "Failed to identify platform")
  lift $ installBin p version

handleError :: ErrorMessage -> ExceptT ErrorMessage Aff Unit
handleError msg = liftEffect $ error (show msg) *> exit 1

mainAff :: String -> ExceptT ErrorMessage Aff Unit
mainAff authToken = do
  let fetchedLatestVersion = withExceptT (ErrorMessage <<< show) $
        fetchLatestRelease
          { authToken
          , owner: "greglook"
          , repo: "cljstyle"
          }
  version <- specifiedVersion <|> fetchedLatestVersion
  usingCache version <|> newlyInstallBin version

main :: Effect Unit
main = do
  authToken <- getAuthToken
  launchAff_ $ runExceptT $ catchError (mainAff authToken) handleError
