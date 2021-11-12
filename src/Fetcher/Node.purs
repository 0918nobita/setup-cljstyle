module Fetcher.Node where

import Control.Monad.Trans.Class (lift)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Fetcher (class Fetcher)
import Prelude

foreign import _getTextImpl :: { url :: String, authorization :: String } -> EffectFnAff String

getTextImpl :: { url :: String, authorization :: String } -> Aff String
getTextImpl = fromEffectFnAff <<< _getTextImpl

data NodeFetcher = NodeFetcher

instance Fetcher NodeFetcher where
  getText NodeFetcher = lift <<< getTextImpl
