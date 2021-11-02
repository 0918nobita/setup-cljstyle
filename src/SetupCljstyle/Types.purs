module SetupCljstyle.Types where

import Prelude

newtype Version = Version String

instance showVersion :: Show Version where
  show (Version v) = v

newtype SingleError a = SingleError a

instance eqSingleError :: Eq a => Eq (SingleError a) where
  eq (SingleError a) (SingleError b) = a == b

instance showSingleError :: Show a => Show (SingleError a) where
  show (SingleError msg) = show msg

instance semigroupSingleError :: Semigroup (SingleError a) where
  append _ e = e
