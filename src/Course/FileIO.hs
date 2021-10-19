{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RebindableSyntax #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE NoImplicitPrelude #-}

module Course.FileIO where

import Course.Applicative
import Course.Core
import Course.Functor
import Course.List
import Course.Monad
import Course.State (put)

{-

Useful Functions --

  getArgs :: IO (List Chars)
  putStrLn :: Chars -> IO ()
  readFile :: FilePath -> IO Chars
  lines :: Chars -> List Chars
  void :: IO a -> IO ()

Abstractions --
  Applicative, Monad:

    <$>, <*>, >>=, =<<, pure

Tuple Functions that could help --

  fst :: (a, b) -> a
  snd :: (a, b) -> b
  (,) :: a -> b -> (a, b)

Problem --
  Given a single argument of a file name, read that file,
  each line of that file contains the name of another file,
  read the referenced file and print out its name and contents.

Consideration --
  Try to avoid repetition. Factor out any common expressions.

Example --
Given file files.txt, containing:
  a.txt
  b.txt
  c.txt

And a.txt, containing:
  the contents of a

And b.txt, containing:
  the contents of b

And c.txt, containing:
  the contents of c

To test this module, load ghci in the root of the project directory, and do
    >> :main "share/files.txt"

Example output:

$ ghci
GHCi, version ...
Loading package...
Loading ...
[ 1 of 28] Compiling (etc...
...
Ok, modules loaded: Course, etc...
>> :main "share/files.txt"
============ share/a.txt
the contents of a

============ share/b.txt
the contents of b

============ share/c.txt
the contents of c

-}

-- <$> :: (a -> b) -> k a -> k b      // fmap
-- <*> :: k (a -> b) -> k a -> k b    // apply
-- =<< :: (a -> k b) -> k a -> k b    // bind

-- Given the file name, and file contents, print them.
-- Use @putStrLn@.
printFile :: FilePath -> Chars -> IO ()
printFile file chars = putStrLn ("============ " ++ file ++ "\n" ++ chars)

-- Given a list of (file name and file contents), print each.
-- Use @printFile@.
printFiles :: List (FilePath, Chars) -> IO ()
printFiles files =
  let printOne (filepath, chars) = printFile filepath chars
   in let xs = (\x -> printOne x) <$> files
       in let y = sequence xs
           in void y

-- Given a file name, return (file name and file contents).
-- Use @readFile@.
-- readFile :: FilePatch -> IO Chars
getFile :: FilePath -> IO (FilePath, Chars)
getFile f =
  let x = readFile f
   in let y = (\chars -> (f, chars)) <$> x
       in y

-- Given a list of file names, return list of (file name and file contents).
-- Use @getFile@.
getFiles :: List FilePath -> IO (List (FilePath, Chars))
getFiles files = sequence (getFile <$> files)

--  in error "todo: Course.FileIO#getFiles"

-- Given a file name, read it and for each line in that file, read and print contents of each.
-- Use @getFiles@, @lines@, and @printFiles@.
run :: FilePath -> IO ()
run fp =
  let x = readFile fp
   in let y = lines <$> x
       in let z = getFiles =<< y
           in let q = printFiles =<< z
               in q

--  printFiles =<< getFiles (f :. Nil)

-- /Tip:/ use @getArgs@ and @run@
main :: IO ()
main =
  getArgs >>= \case
    Nil -> putStrLn "no args"
    xs :. _ -> run xs

-- error "todo: Course.FileIO#main"

----

-- Was there was some repetition in our solution?
-- ? `sequence . (<$>)`
-- ? `void . sequence . (<$>)`
-- Factor it out.
