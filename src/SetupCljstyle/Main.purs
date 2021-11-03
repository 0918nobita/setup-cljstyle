module SetupCljstyle.Main
  ( main
  ) where

import Control.Alt ((<|>))
import Control.Monad.Except (ExceptT, throwError, catchError, mapExceptT, runExceptT)
import Control.Monad.Reader (runReaderT)
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (errorShow)
import GitHub.Actions.Core (addPath, group)
import Node.Platform (Platform(Win32, Darwin, Linux))
import Node.Process as Process
import Prelude
import SetupCljstyle.Cache (cache)
import SetupCljstyle.Cmd (execCmd)
import SetupCljstyle.Inputs (gatherInputs)
import SetupCljstyle.Installer (class HasInstaller, runInstaller)
import SetupCljstyle.Installer.Win32 as Win32
import SetupCljstyle.Installer.Darwin as Darwin
import SetupCljstyle.Installer.Linux as Linux
import SetupCljstyle.Types (SingleError(..))

group' :: forall e a. String -> ExceptT e Aff a -> ExceptT e Aff a
group' name = mapExceptT \aff -> group { fn: aff, name }

mainAff :: forall a. (HasInstaller a) => a -> ExceptT (SingleError String) Aff Unit
mainAff installer = do
  { cljstyleVersion: version, runCheck } <- group' "Gather inputs" gatherInputs

  group' ("Install cljstyle " <> show version) do
    cachePath <- runReaderT (cache <|> runInstaller installer) version
    liftEffect $ addPath cachePath

  when runCheck $ lift $ group
    { name: "Run `cljstyle check`"
    , fn: execCmd "cljstyle" [ "check", "--verbose" ]
    }

handleError :: forall a b. Show a => SingleError a -> ExceptT b Aff Unit
handleError msg = do
  errorShow msg
  liftEffect $ Process.exit 1

main :: Effect Unit
main =
  launchAff_ $ runExceptT $ catchError mainAff' handleError
  where
  mainAff' = case Process.platform of
    Just Win32 ->
      mainAff Win32.installer
    Just Darwin ->
      mainAff Darwin.installer
    Just Linux ->
      mainAff Linux.installer
    Just _ -> throwError $ SingleError "Unsupported platform"
    Nothing -> throwError $ SingleError "Failed to identify platform"
