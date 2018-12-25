module Main (solve) where

import Control.Monad.Free (Free)
import Data.Int (fromString)
import Data.List (List(..), all, fromFoldable, intercalate, null, zipWith)
import Data.Maybe (fromMaybe)
import Data.String as S
import Data.Tuple.Nested (Tuple4, (/\))
import Prelude (bind, discard, map, pure, show, unit, ($), (*>), (+), (-), (<<<), (<>), (>=))
import Text.Smolder.HTML (h2, span, table, td, tr)
import Text.Smolder.HTML.Attributes (className, colspan)
import Text.Smolder.Markup (Markup, MarkupM, (!), text)
import Text.Smolder.Renderer.String (render)

type IntVec = List Int
type IntMat = List IntVec

printVec :: IntVec -> String
printVec xs = "[" <> intercalate " " (map show xs) <> "]"

printMat :: IntMat -> String
printMat xs = "[" <> intercalate " " (map printVec xs) <> "]"

readIntVec :: String -> IntVec
readIntVec = fromFoldable <<< map (fromMaybe 0 <<< fromString) <<< S.split (S.Pattern " ")

readIntMat :: String -> IntMat
readIntMat = fromFoldable <<< map readIntVec <<< S.split (S.Pattern "\n")

handleProc :: forall e. IntMat -> IntMat -> IntVec -> Free (MarkupM e) (Tuple4 Boolean IntMat IntMat IntVec)
handleProc Nil Nil x = pure $ false /\ Nil /\ Nil /\ x /\ unit
handleProc (Cons allocV allocM) (Cons maxiV maxiM) availV = do
  let needV      = zipWith (-) maxiV allocV
      testAllocV = zipWith (-) availV needV
      canAlloc   = all (\nn -> nn >= 0) testAllocV
      m = do
        tr $ (td $ text "Allocated")                            *> (td $ text $ printVec allocV)
        tr $ (td $ text "Maximum")                              *> (td $ text $ printVec maxiV)
        tr $ (td $ text "Needed (= Maximum - Allocated)")       *> (td $ text $ printVec needV)
        tr $ (td $ text "Available")                            *> (td $ text $ printVec availV)
        tr $ (td $ text "Test Allocate (= Available - Needed)") *> (td $ text $ printVec testAllocV)
  if canAlloc
    then do
      let availV' = zipWith (+) allocV availV
      table $ m *> (tr $ td ! colspan "2" $ span ! className "alloc" $ text "Can allocate.")
      _ /\ a /\ b /\ c /\ _ <- handleProc allocM maxiM availV'
      pure $ true /\ a /\ b /\ c /\ unit
    else do
      table $ m *> (tr $ td ! colspan "2" $ span ! className "unalloc" $ text "Cannot allocate.")
      isSafe /\ allocM' /\ maxiM' /\ availV' /\ _ <- handleProc allocM maxiM availV
      pure $ isSafe /\ Cons allocV allocM' /\ Cons maxiV maxiM' /\ availV' /\ unit
handleProc a b c = pure $ false /\ a /\ b /\ c /\ unit  -- FIXME: should be never reached

handleConstr :: forall e. IntMat -> IntMat -> IntVec -> Markup e
handleConstr allocM maxiM availV = do
  h2 $ text $ "Checking for " <> printMat allocM
  isSafe /\ a /\ b /\ c /\ _ <- handleProc allocM maxiM availV
  case isSafe, null a of
    true , false -> handleConstr a b c
    false, _     -> h2 $ text "Not safe."
    true , true  -> h2 $ text "Safe."

solve :: String -> String -> String -> String
solve allocM maxiM availV = render $ handleConstr (readIntMat allocM) (readIntMat maxiM) (readIntVec availV)
