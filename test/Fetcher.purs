module Test.Fetcher where

import Fetcher (class Fetcher)
import Prelude

data TestFetcher = TestFetcher String

instance Fetcher TestFetcher where
  getText (TestFetcher resBody) _ = pure resBody
