module SetupCljstyle.Main
  ( main
  ) where

import Control.Alt ((<|>))
import Control.Monad.Except (ExceptT, throwError, catchError, except, mapExceptT, runExceptT, withExceptT)
import Control.Monad.Reader (ReaderT, asks, runReaderT)
import Control.Monad.Trans.Class (lift)
import Data.Either (Either)
import Data.EitherR (fmapL)
import Data.Maybe (Maybe(..))
import Data.String (null)
import Data.String.Regex (Regex, regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (error, errorShow, log)
import GitHub.Actions.Core (addPath, endGroup, group, startGroup)
import GitHub.Actions.ToolCache (find)
import GitHub.RestApi.Releases (fetchLatestRelease)
import Node.Buffer as Buf
import Node.ChildProcess (Exit(Normally), defaultSpawnOptions, onExit, spawn, stderr, stdout)
import Node.Encoding (Encoding(UTF8))
import Node.Path (FilePath)
import Node.Process as Process
import Node.Stream (onData)
import Prelude
import SetupCljstyle.Inputs (authTokenInput, cljstyleVersionInput, runCheckInput)
import SetupCljstyle.Installer (tryInstallBin)
import SetupCljstyle.Types (SingleError(..), Version(..))

versionRegex :: Either (SingleError String) Regex
versionRegex = regex "^([1-9]\\d*|0)\\.([1-9]\\d*|0)\\.([1-9]\\d*|0)$" noFlags # fmapL SingleError

tryGetSpecifiedVer :: ExceptT (SingleError String) Aff Version
tryGetSpecifiedVer = do
  log "Attempting to get specified version"
  version <- mapExceptT liftEffect cljstyleVersionInput
  log $ "Specificed version: " <> version
  if null version then
    throwError $ SingleError "Version is not specified"
  else do
    verRegex <- except versionRegex
    if test verRegex version then
      pure $ Version version
    else
      throwError $ SingleError "The format of cljstyle-version is invalid."

tryGetLatestVer :: ExceptT (SingleError String) Aff Version
tryGetLatestVer = do
  log "Attempting to get the latest version"
  authToken <- mapExceptT liftEffect authTokenInput
  fetchLatestRelease { authToken, owner: "greglook", repo: "cljstyle" }

tryUseCache :: ReaderT Version (ExceptT (SingleError String) Aff) FilePath
tryUseCache = do
  versionSpec <- asks show

  lift $ mapExceptT liftEffect do
    cachePath <- find { toolName: "cljstyle", versionSpec, arch: Nothing }
      # withExceptT \_ -> SingleError "Cache not found"
    case cachePath of
      Just p -> pure p
      Nothing -> throwError $ SingleError "Failed to get cache path"

group' :: forall e a. String -> ExceptT e Aff a -> ExceptT e Aff a
group' name = mapExceptT \aff -> group { fn: aff, name }

mainAff :: ExceptT (SingleError String) Aff Unit
mainAff = do
  runCheck <- mapExceptT liftEffect runCheckInput

  version <- group' "🔖 Determining the version of cljstyle installed" do
    version <- tryGetSpecifiedVer <|> tryGetLatestVer
    log $ "Determined version: " <> show version
    pure version

  group' ("➕ Installing cljstyle " <> show version) do
    cachePath <- runReaderT (tryUseCache <|> tryInstallBin) version
    liftEffect $ addPath cachePath

  when runCheck do
    liftEffect do
      startGroup "▶️ Run `cljstyle check`"
      cljstyleCheck <- spawn "cljstyle" [ "check", "--verbose" ] defaultSpawnOptions
      onExit cljstyleCheck \exit -> do
        endGroup
        case exit of
          Normally 0 -> Process.exit 0
          _ -> Process.exit 1
      onData (stdout cljstyleCheck) \buf -> Buf.toString UTF8 buf >>= log
      onData (stderr cljstyleCheck) \buf -> Buf.toString UTF8 buf >>= error

handleError :: forall a b. Show a => SingleError a -> ExceptT b Aff Unit
handleError msg = do
  errorShow msg
  liftEffect $ Process.exit 1

main :: Effect Unit
main = launchAff_ $ runExceptT $ catchError mainAff handleError
