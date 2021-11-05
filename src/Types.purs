module Types where

import Control.Monad.Except (ExceptT)
import Effect (Effect)
import Effect.Aff (Aff)
import Prelude

type EffectWithExcept = ExceptT (SingleError String) Effect

type AffWithExcept = ExceptT (SingleError String) Aff

newtype Version = Version String

instance Eq Version where
  eq (Version a) (Version b) = a == b

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
