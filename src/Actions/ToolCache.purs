module Actions.ToolCache
  ( cacheDir
  , extractTar
  , downloadTool
  , find
  ) where

import Prelude

import Control.Promise (Promise, toAff)
import Effect (Effect)
import Effect.Aff (Aff)

foreign import _cacheDir :: String -> String -> String -> Promise String

cacheDir :: String -> String -> String -> Aff String
cacheDir sourceDir tool = toAff <<< _cacheDir sourceDir tool

foreign import _extractTar :: String -> String -> Promise String

extractTar :: String -> String -> Aff String
extractTar file = toAff <<< _extractTar file

foreign import _downloadTool :: String -> Promise String

downloadTool :: String -> Aff String
downloadTool = toAff <<< _downloadTool

foreign import find :: String -> String -> Effect String
