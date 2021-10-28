module SetupCljstyle.Types where

import Prelude

newtype Version = Version String

instance showVersion :: Show Version where
  show (Version v) = v

type ErrorMessage = String
