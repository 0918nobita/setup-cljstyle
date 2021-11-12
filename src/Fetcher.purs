module Fetcher where

import Types (AffWithExcept)

class Fetcher a where
  getText :: a -> { url :: String, authorization :: String } -> AffWithExcept String
