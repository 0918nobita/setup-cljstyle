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
import Fetcher.Node (nodeTextFetcher)
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
import SetupCljstyle.RawInputSource (class HasRawInputs, gatherRawInputs)
import SetupCljstyle.RawInputSource.GitHubActions (ghaRawInputSource)
import Types (SingleError(..), AffWithExcept)

type Env r =
  { fetcher :: TextFetcher
  , installer :: Installer
  , rawInputSource :: r
  }

mainReaderT
  :: forall r
   . HasRawInputs r
  => ReaderT (Env r) AffWithExcept Unit
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
    RunCheck _ -> group "Run `cljstyle check`" $ liftEffect $ execCmd "cljstyle check --verbose"
    DontRunCheck -> mempty

mainWin32 :: AffWithExcept Unit
mainWin32 = runReaderT mainReaderT
  { fetcher: nodeTextFetcher
  , installer: Win32.installer
  , rawInputSource: ghaRawInputSource
  }

mainDarwin :: AffWithExcept Unit
mainDarwin = runReaderT mainReaderT
  { fetcher: nodeTextFetcher
  , installer: Darwin.installer
  , rawInputSource: ghaRawInputSource
  }

mainLinux :: AffWithExcept Unit
mainLinux = runReaderT mainReaderT
  { fetcher: nodeTextFetcher
  , installer: Linux.installer
  , rawInputSource: ghaRawInputSource
  }

main :: Effect Unit
main =
  launchAff_ $ runExceptT $ catchError mainAff' handleError
  where
  mainAff' = case Process.platform of
    Just Win32 -> mainWin32
    Just Darwin -> mainDarwin
    Just Linux -> mainLinux
    Just _ -> throwError $ SingleError "Unsupported platform"
    Nothing -> throwError $ SingleError "Failed to identify platform"

  handleError msg = liftEffect $ errorShow msg *> Process.exit 1
