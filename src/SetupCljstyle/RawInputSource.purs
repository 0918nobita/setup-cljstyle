module SetupCljstyle.RawInputSource where

import Types (AffWithExcept)

type RawInputs =
  { cljstyleVersion :: String
  , authToken :: String
  , runCheck :: String
  }

newtype RawInputSource = RawInputSource (AffWithExcept RawInputs)

gatherRawInputs :: RawInputSource -> AffWithExcept RawInputs
gatherRawInputs (RawInputSource aff) = aff
