module Node.Os where

import Effect (Effect)

foreign import homedir :: Effect String
