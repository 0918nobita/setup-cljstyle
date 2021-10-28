module SetupCljstyle.Types where

import Prelude

newtype Version = Version String

instance showVersion :: Show Version where
  show (Version v) = v

newtype ErrorMessage = ErrorMessage String

instance showErrorMessage :: Show ErrorMessage where
  show (ErrorMessage msg) = msg

instance semigroupErrMsg :: Semigroup ErrorMessage where
  append _ e = e
