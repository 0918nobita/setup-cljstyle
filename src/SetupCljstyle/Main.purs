module SetupCljstyle.Main
  ( main
  ) where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Except (ExceptT(..), catchError, except, mapExceptT, runExceptT, withExceptT)
import Control.Monad.Trans.Class (lift)
import Data.Either (Either(..))
import Data.String.Regex (Regex, regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error)
import GitHub.Actions.Core (InputOption(..), addPath, getInput)
import GitHub.Actions.ToolCache (find)
import GitHub.RestApi.Releases (fetchLatestRelease)
import Node.Process (exit)
import Node.ProcessExt (platform)
import SetupCljstyle.Installer (installBin)
import SetupCljstyle.Types (Version, ErrorMessage)

getVerOption :: Effect String
getVerOption =
  getInput "cljstyle-version" $ InputOption { required: false, trimWhitespace: false }

getAuthToken :: Effect String
getAuthToken =
  getInput "token" $ InputOption { required: false, trimWhitespace: false }

versionRegex :: Either ErrorMessage Regex
versionRegex =
  regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags

specifiedVersion :: ExceptT ErrorMessage Aff Version
specifiedVersion = mapExceptT liftEffect $ ExceptT do
  version <- getVerOption

  pure if version == ""
    then Left "Version is not specified\n"
    else do
      verRegex <- versionRegex

      if test verRegex version
        then Right version
        else Left "The format of cljstyle-version is invalid.\n"

usingCache :: Version -> ExceptT ErrorMessage Aff Unit
usingCache version = mapExceptT liftEffect do
  cachePath <- find "cljstyle" version # withExceptT (\_ -> "Cache not found\n")
  lift $ addPath cachePath

newlyInstallBin :: Version -> ExceptT ErrorMessage Aff Unit
newlyInstallBin version = mapExceptT liftEffect do
  p <- except platform # withExceptT (\_ -> "Failed to identify platform\n")
  lift $ installBin p version

handleError :: ErrorMessage -> ExceptT ErrorMessage Aff Unit
handleError msg = liftEffect $ error msg *> exit 1

mainAff :: String -> ExceptT ErrorMessage Aff Unit
mainAff authToken = do
  let fetchedLatestVersion = withExceptT show $
        fetchLatestRelease {
          authToken,
          owner: "greglook",
          repo: "cljstyle"
        }
  version <- specifiedVersion <|> fetchedLatestVersion
  usingCache version <|> newlyInstallBin version

main :: Effect Unit
main = do
  authToken <- getAuthToken
  launchAff_ $ runExceptT $ catchError (mainAff authToken) handleError
