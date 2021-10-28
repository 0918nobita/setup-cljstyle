module SetupCljstyle.Types where

import Prelude

newtype Version
  = Version String

instance showVersion :: Show Version where
  show (Version v) = v

newtype ErrorMessage
  = ErrorMessage String

instance eqErrorMessage :: Eq ErrorMessage where
  eq (ErrorMessage a) (ErrorMessage b) = a == b

instance showErrorMessage :: Show ErrorMessage where
  show (ErrorMessage msg) = msg

instance semigroupErrMsg :: Semigroup ErrorMessage where
  append _ e = e
