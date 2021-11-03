module SetupCljstyle.Types where

import Prelude

-- | Version of cljstyle
newtype Version = Version String

instance Show Version where
  show (Version v) = v

-- | `SingleError a` contains `a` that represents its reason.
-- | This is intended to be used in data structures such as `ExceptT`,
-- | where the error values are concatenated with `append`.
newtype SingleError a = SingleError a

instance Eq a => Eq (SingleError a) where
  eq (SingleError a) (SingleError b) = a == b

instance Show a => Show (SingleError a) where
  show (SingleError msg) = show msg

instance Semigroup (SingleError a) where
  append _ e = e
