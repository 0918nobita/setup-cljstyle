module SetupCljstyle.Main where

import Prelude

import Actions.Core (InputOption(..), addPath, getInput)
import Actions.ToolCache (find)
import Control.Monad.Except (ExceptT, except, runExceptT)
import Control.Monad.Trans.Class (lift)
import Data.Either (Either(..), either)
import Data.Maybe (Maybe(..))
import Data.String.Regex (regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Class.Console (error)
import Node.Platform (Platform(Win32, Darwin))
import Node.Process (exit, platform)
import SetupCljstyle.Win32 as Win32
import SetupCljstyle.Darwin as Darwin
import SetupCljstyle.Linux as Linux
import SetupCljstyle.Types (ErrorMessage, Version)

installBin :: Platform -> Version -> Effect Unit
installBin Win32  = Win32.installBin
installBin Darwin = Darwin.installBin
installBin _      = Linux.installBin

main :: Effect Unit
main =
  runExceptT mainExceptT
    >>= either
      (\e -> error e *> exit 1)
      (\_ -> mempty)
  where
    mainExceptT :: ExceptT ErrorMessage Effect Unit
    mainExceptT = do
      version <- lift $ getInput "cljstyle-version" (InputOption { required: false, trimWhitespace: false })

      verRegex <- except $ regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags

      if test verRegex version
        then do
          foundCache <- lift $ find "cljstyle" version
          case foundCache of
            "" ->
              case platform of
                Just p -> lift $ installBin p version
                Nothing ->
                  except $ Left "Failed to identify platform"
            cachePath ->
              lift $ addPath cachePath
        else
          except $ Left "The format of cljstyle-version is invalid."