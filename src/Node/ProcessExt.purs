module Node.ProcessExt where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Node.Platform (Platform)
import Node.Process as Process

platform :: Either Unit Platform
platform =
  case Process.platform of
    Just p -> Right p
    Nothing -> Left unit
