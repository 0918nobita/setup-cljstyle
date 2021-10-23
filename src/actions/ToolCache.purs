module Actions.ToolCache where

import Effect (Effect)

foreign import find :: String -> String -> Effect String
