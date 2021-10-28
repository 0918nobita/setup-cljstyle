module GitHub.Actions.ToolCache
  ( cacheDir
  , extractTar
  , downloadTool
  , find
  ) where

import Prelude
import Control.Monad.Except (ExceptT(..))
import Control.Promise (Promise, toAff)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff)
import Milkis (URL(..))
import SetupCljstyle.Types (Version(..))

foreign import _cacheDir :: String -> String -> String -> Promise String

cacheDir :: String -> String -> Version -> Aff String
cacheDir sourceDir tool (Version version) = toAff $ _cacheDir sourceDir tool version

foreign import _extractTar :: String -> String -> Promise String

extractTar :: String -> String -> Aff String
extractTar file = toAff <<< _extractTar file

foreign import _downloadTool :: String -> Promise String

downloadTool :: URL -> Aff String
downloadTool (URL url) = toAff $ _downloadTool url

foreign import _find :: String -> String -> Effect String

find :: String -> Version -> ExceptT Unit Effect String
find toolName (Version version) =
  ExceptT do
    pathOpt <- _find toolName version
    pure case pathOpt of
      "" -> Left unit
      p -> Right p
