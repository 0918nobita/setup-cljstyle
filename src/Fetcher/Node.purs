module Fetcher.Node
  ( NodeFetcher(..)
  ) where

import Prelude

import Control.Monad.Trans.Class (lift)
import Effect.Aff (Aff)
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Fetcher (class Fetcher)

type GetTextArgs = { url :: String, authorization :: String }

foreign import _getTextImpl :: GetTextArgs -> EffectFnAff String

getTextImpl :: GetTextArgs -> Aff String
getTextImpl = fromEffectFnAff <<< _getTextImpl

data NodeFetcher = NodeFetcher

instance Fetcher NodeFetcher where
  getText NodeFetcher = lift <<< getTextImpl
