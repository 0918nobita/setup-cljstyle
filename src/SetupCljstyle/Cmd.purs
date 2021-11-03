module SetupCljstyle.Cmd where

import Data.Either (Either(..))
import Effect.Aff (Aff, makeAff)
import Effect.Aff as Aff
import Effect.Class.Console (log, error)
import Node.Buffer as Buf
import Node.ChildProcess (Exit(Normally), defaultSpawnOptions, onExit, spawn, stderr, stdout)
import Node.Encoding (Encoding(UTF8))
import Node.Stream (onData)
import Prelude

-- | Asynchronously run a shell command.
-- | Its stdout and stderr are piped to the current process.
execCmd :: String -> Array String -> Aff Unit
execCmd cmd args = makeAff lowLevelEffect
  where
  noopCanceler = mempty

  lowLevelEffect callback = do
    childProcess <- spawn cmd args defaultSpawnOptions
    onExit childProcess \exit ->
      case exit of
        Normally 0 -> callback $ Right unit
        e -> callback $ Left $ Aff.error $ "Exit status: " <> show e
    onData (stdout childProcess) \buf -> Buf.toString UTF8 buf >>= log
    onData (stderr childProcess) \buf -> Buf.toString UTF8 buf >>= error
    pure noopCanceler
