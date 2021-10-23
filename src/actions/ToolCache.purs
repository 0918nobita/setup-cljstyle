module Actions.ToolCache
  ( downloadTool
  , find
  ) where

import Prelude

import Control.Promise (Promise, toAff)
import Effect (Effect)
import Effect.Aff (Aff)

foreign import _downloadTool :: String -> Promise String

downloadTool :: String -> Aff String
downloadTool url = toAff $ _downloadTool url

foreign import find :: String -> String -> Effect String
