module Actions.Core where

import Effect (Effect)
import Prelude

foreign import addPath :: String -> Effect Unit

data InputOption = InputOption
  { required :: Boolean
  , trimWhitespace :: Boolean
  }

foreign import getInput :: String -> InputOption -> Effect String
