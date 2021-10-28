module GitHub.Actions.Io where

import Prelude
import Control.Promise (Promise, toAff)
import Effect.Aff (Aff)

foreign import _mkdirP :: String -> Promise Unit

mkdirP :: String -> Aff Unit
mkdirP = toAff <<< _mkdirP

foreign import _mv :: String -> String -> Promise Unit

mv :: String -> String -> Aff Unit
mv source = toAff <<< _mv source
