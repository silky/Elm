module Main where

import Control.Monad (unless)
import Data.List (isInfixOf)
import System.Directory
import System.Exit
import System.FilePath
import System.Process

import Elm.Internal.Paths as Elm

main :: IO ()
main = do
  top <- getCurrentDirectory
  let ioScript s = top</>"IO"</>s
  runCmd "git submodule update --init"
  out <- readProcess "npm" ["ls", "--parseable"] ""
  unless ("jsdom" `isInfixOf` out) $ runCmd "npm install jsdom"
  setCurrentDirectory $ top</>"tests"</>"elm"
  runCmd $ concat [top</>"dist"</>"build"</>"elm"</>"elm --make --only-js --src-dir=" , top</>"automaton", " --src-dir=", top</>"IO", " --src-dir=", top</>"Elm-Test", " Test.elm"]
  runCmd $ unwords ["cat ", ioScript "prescript.js", Elm.runtime, "build"</>"Test.js", ioScript "handler.js", "> exe.js"]
  exitWith =<< waitForProcess =<< (runCommand "node exe.js")
  where runCmd cmd = do
          putStrLn cmd
          exitCode <- waitForProcess =<< runCommand cmd
          case exitCode of
            ExitSuccess   -> return ()
            ExitFailure _ -> error "something went wrong"

          
