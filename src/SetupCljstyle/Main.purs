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
import Fetcher (TextFetcher)
import Fetcher.Node (textFetcher)
import GitHub.Actions.Extension (addPath, group)
import Node.Platform (Platform(Win32, Darwin, Linux))
import Node.Process as Process
import SetupCljstyle.Cache (cache)
import SetupCljstyle.Command (execCmd)
import SetupCljstyle.InputResolver (RunCheckInput(..), resolveInputs)
import SetupCljstyle.Installer (Installer, runInstaller)
import SetupCljstyle.Installer.Darwin as Darwin
import SetupCljstyle.Installer.Linux as Linux
import SetupCljstyle.Installer.Win32 as Win32
import SetupCljstyle.RawInputSource (RawInputSource, gatherRawInputs)
import SetupCljstyle.RawInputSource.GitHubActions (rawInputSource)
import Types (SingleError(..), AffWithExcept)

type Env =
  { fetcher :: TextFetcher
  , installer :: Installer
  , rawInputSource :: RawInputSource
  }

mainReaderT :: ReaderT Env AffWithExcept Unit
mainReaderT = do
  { installer, rawInputSource } <- ask

  rawInputs <- lift $ gatherRawInputs rawInputSource

  { cljstyleVersion, runCheck } <-
    mapReaderT (group "Gather inputs")
      $ withReaderT (\r -> { fetcher: r.fetcher, rawInputs }) resolveInputs

  mapReaderT (group ("Install cljstyle " <> show cljstyleVersion)) do
    cachePath <- withReaderT (\_ -> cljstyleVersion) $ cache <|> runInstaller installer
    lift $ addPath cachePath

  lift case runCheck of
    RunCheck reviewdogEnabled -> do
      group "Run `cljstyle check`" $ liftEffect $ execCmd "cljstyle check --verbose"
      if reviewdogEnabled then
        liftEffect $ execCmd "cljstyle check --no-color | reviewdog -f=diff -reporter=github-check"
      else mempty
    DontRunCheck -> mempty

main :: Effect Unit
main =
  launchAff_ $ runExceptT $ catchError mainAff' handleError
  where
  mainAff' = do
    installer <- case Process.platform of
      Just Win32 -> pure Win32.installer
      Just Darwin -> pure Darwin.installer
      Just Linux -> pure Linux.installer
      Just _ -> throwError $ SingleError "Unsupported platform"
      Nothing -> throwError $ SingleError "Failed to identify platform"
    runReaderT mainReaderT { fetcher: textFetcher, installer, rawInputSource }

  handleError msg = liftEffect $ errorShow msg *> Process.exit 1
