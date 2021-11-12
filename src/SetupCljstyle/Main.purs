module SetupCljstyle.Main
  ( main
  ) where

import Control.Alt ((<|>))
import Control.Monad.Except (throwError, catchError, runExceptT)
import Control.Monad.Reader (runReaderT)
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (errorShow)
import GitHub.Actions.Core (addPath)
import GitHub.Actions.Extension (group, groupExceptT)
import Node.Platform (Platform(Win32, Darwin, Linux))
import Node.Process as Process
import Prelude
import SetupCljstyle.Cache (cache)
import SetupCljstyle.Command (execCmd)
import SetupCljstyle.InputResolver (resolveInputs)
import SetupCljstyle.Installer (class HasInstaller, runInstaller)
import SetupCljstyle.Installer.Win32 as Win32
import SetupCljstyle.Installer.Darwin as Darwin
import SetupCljstyle.Installer.Linux as Linux
import SetupCljstyle.RawInputSource (class HasRawInputs, gatherRawInputs)
import SetupCljstyle.RawInputSource.GitHubActions (ghaRawInputSource)
import Types (AffWithExcept, SingleError(..))

mainAff :: forall a b. HasInstaller a => HasRawInputs b => a -> b -> AffWithExcept Unit
mainAff installer inputSource = do
  rawInputs <- gatherRawInputs inputSource

  { cljstyleVersion: version, runCheck } <-
    groupExceptT "Gather inputs" $ resolveInputs rawInputs

  groupExceptT ("Install cljstyle " <> show version) do
    cachePath <- runReaderT (cache <|> runInstaller installer) version
    liftEffect $ addPath cachePath

  when runCheck $ lift
    $ group "Run `cljstyle check`"
    $ execCmd "cljstyle" [ "check", "--verbose" ]

main :: Effect Unit
main =
  launchAff_ $ runExceptT $ catchError mainAff' handleError
  where
  mainAff' = case Process.platform of
    Just Win32 ->
      mainAff Win32.installer ghaRawInputSource
    Just Darwin ->
      mainAff Darwin.installer ghaRawInputSource
    Just Linux ->
      mainAff Linux.installer ghaRawInputSource
    Just _ -> throwError $ SingleError "Unsupported platform"
    Nothing -> throwError $ SingleError "Failed to identify platform"

  handleError msg = liftEffect $ errorShow msg *> Process.exit 1
