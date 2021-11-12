module Test.Fetcher where

import Fetcher (class Fetcher)
import Prelude

data TestFetcher = TestFetcher

instance Fetcher TestFetcher where
  getText TestFetcher _ = pure "{}"
