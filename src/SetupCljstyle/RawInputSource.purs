module SetupCljstyle.RawInputSource where

import Types (AffWithExcept)

type RawInputs =
  { cljstyleVersion :: String
  , authToken :: String
  , runCheck :: String
  }

class HasRawInputs a where
  gatherRawInputs :: a -> AffWithExcept RawInputs
