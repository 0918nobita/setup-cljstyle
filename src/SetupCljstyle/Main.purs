module SetupCljstyle.Main
  ( main
  ) where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Except (ExceptT, except, mapExceptT, runExceptT, withExceptT)
import Control.Monad.Trans.Class (lift)
import Data.Either (Either(..), either)
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

versionRegex :: Either ErrorMessage Regex
versionRegex =
  regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags

specifiedVersion :: ExceptT ErrorMessage Aff Version
specifiedVersion = do
  version <- liftEffect getVerOption
  if version == ""
    then except $ Left "Version is not specified"
    else do
      verRegex <- except versionRegex

      except $ if test verRegex version
        then Right version
        else Left "The format of cljstyle-version is invalid."

usingCache :: Version -> ExceptT ErrorMessage Aff Unit
usingCache version = mapExceptT liftEffect do
  cachePath <- find "cljstyle" version # withExceptT (\_ -> "Cache not found")
  lift $ addPath cachePath

newlyInstallBin :: Version -> ExceptT ErrorMessage Aff Unit
newlyInstallBin version = mapExceptT liftEffect do
  p <- except platform # withExceptT (\_ -> "Failed to identify platform")
  lift $ installBin p version

mainExceptT :: ExceptT ErrorMessage Effect Unit
mainExceptT = do
  lift $ launchAff_ $ runExceptT do
    version <- specifiedVersion <|> (fetchLatestRelease "greglook" "cljstyle" # withExceptT show)
    (usingCache version) <|> (newlyInstallBin version)

main :: Effect Unit
main =
  runExceptT mainExceptT
    >>= either
      (\e -> error e *> exit 1)
      (\_ -> mempty)
