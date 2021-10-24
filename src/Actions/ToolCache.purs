module Actions.ToolCache
  ( extractTar
  , downloadTool
  , find
  ) where

import Prelude

import Control.Promise (Promise, toAff)
import Effect (Effect)
import Effect.Aff (Aff)

foreign import _extractTar :: String -> String -> Promise String

extractTar :: String -> String -> Aff String
extractTar file dest = toAff $ _extractTar file dest

foreign import _downloadTool :: String -> Promise String

downloadTool :: String -> Aff String
downloadTool url = toAff $ _downloadTool url

foreign import find :: String -> String -> Effect String
