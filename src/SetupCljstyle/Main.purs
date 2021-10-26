module SetupCljstyle.Main
  ( main
  ) where

import Prelude

import Control.Monad.Except (ExceptT, except, runExceptT)
import Control.Monad.Trans.Class (lift)
import Data.Either (Either(..), either)
import Data.Maybe (Maybe(..))
import Data.String.Regex (regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Class.Console (error)
import GitHub.Actions.Core (InputOption(..), addPath, getInput)
import GitHub.Actions.ToolCache (find)
import Node.Process (exit, platform)
import SetupCljstyle.Installer (installBin)
import SetupCljstyle.Types (ErrorMessage)

mainExceptT :: ExceptT ErrorMessage Effect Unit
mainExceptT = do
  version <- lift $ getInput "cljstyle-version" $ InputOption { required: false, trimWhitespace: false }

  verRegex <- except $ regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags

  if test verRegex version
    then do
      cachePathOpt <- lift $ find "cljstyle" version
      case cachePathOpt of
        Just cachePath -> lift $ addPath cachePath
        Nothing -> case platform of
          Just p  -> lift $ installBin p version
          Nothing -> except $ Left "Failed to identify platform"
    else
      except $ Left "The format of cljstyle-version is invalid."

main :: Effect Unit
main =
  runExceptT mainExceptT
    >>= either
      (\e -> error e *> exit 1)
      (\_ -> mempty)
