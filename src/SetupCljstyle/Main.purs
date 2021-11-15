module SetupCljstyle.Main
  ( main
  ) where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Except (throwError, catchError, runExceptT)
import Control.Monad.Reader (ReaderT, ask, mapReaderT, runReaderT, withReaderT)
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (errorShow)
import Fetcher (class Fetcher)
import Fetcher.Node (NodeFetcher(..))
import GitHub.Actions.Core (addPath)
import GitHub.Actions.Extension (group)
import Node.Platform (Platform(Win32, Darwin, Linux))
import Node.Process as Process
import SetupCljstyle.Cache (cache)
import SetupCljstyle.Command (execCmd)
import SetupCljstyle.InputResolver (RunCheckInput(..), resolveInputs)
import SetupCljstyle.Installer (class HasInstaller, runInstaller)
import SetupCljstyle.Installer.Darwin as Darwin
import SetupCljstyle.Installer.Linux as Linux
import SetupCljstyle.Installer.Win32 as Win32
import SetupCljstyle.RawInputSource (class HasRawInputs, gatherRawInputs)
import SetupCljstyle.RawInputSource.GitHubActions (ghaRawInputSource)
import Types (AffWithExcept, SingleError(..))

type Env f i r = { fetcher :: f, installer :: i, rawInputSource :: r }

mainReaderT :: forall f i r. Fetcher f => HasInstaller i => HasRawInputs r => ReaderT (Env f i r) AffWithExcept Unit
mainReaderT = do
  { installer, rawInputSource } <- ask

  rawInputs <- lift $ gatherRawInputs rawInputSource

  { cljstyleVersion, runCheck } <- mapReaderT (group "Gather inputs") $ withReaderT (\r -> { fetcher: r.fetcher, rawInputs }) resolveInputs

  mapReaderT (group ("Install cljstyle " <> show cljstyleVersion)) do
    cachePath <- withReaderT (\_ -> cljstyleVersion) $ cache <|> runInstaller installer
    liftEffect $ addPath cachePath

  lift case runCheck of
    RunCheck _ -> group "Run `cljstyle check`" $ lift $ execCmd "cljstyle" [ "check", "--verbose" ]
    DontRunCheck -> mempty

main :: Effect Unit
main =
  launchAff_ $ runExceptT $ catchError mainAff' handleError
  where
  fetcher = NodeFetcher

  rawInputSource = ghaRawInputSource

  mainAff' = case Process.platform of
    Just Win32 ->
      runReaderT mainReaderT { fetcher, installer: Win32.installer, rawInputSource }

    Just Darwin ->
      runReaderT mainReaderT { fetcher, installer: Darwin.installer, rawInputSource }

    Just Linux ->
      runReaderT mainReaderT { fetcher, installer: Linux.installer, rawInputSource }

    Just _ -> throwError $ SingleError "Unsupported platform"

    Nothing -> throwError $ SingleError "Failed to identify platform"

  handleError msg = liftEffect $ errorShow msg *> Process.exit 1
