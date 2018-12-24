module Main (solve) where

import Control.Monad.Free (Free)
import Data.Int (fromString)
import Data.List (List(..), all, fromFoldable, intercalate, null, zipWith)
import Data.Maybe (fromMaybe)
import Data.String as S
import Data.Tuple.Nested (Tuple2, Tuple3, (/\))
import Prelude
import Text.Smolder.HTML hiding (map)
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

handleProc :: forall e. Tuple3 IntMat IntMat IntVec -> Free (MarkupM e) (Tuple2 Boolean (Tuple3 IntMat IntMat IntVec))
handleProc s@(Nil /\ Nil /\ _ /\ _) = pure $ false /\ s /\ unit
handleProc (Cons allocV allocM /\ Cons maxiV maxiM /\ availV /\ _) = do
  let needV      = zipWith (-) maxiV allocV
      testAllocV = zipWith (-) availV needV
      canAlloc   = all (\nn -> nn >= 0) testAllocV
      m = do
        tr $ (td $ text "Allocated") *> (td $ text $ printVec allocV)
        tr $ (td $ text "Maximum") *> (td $ text $ printVec maxiV)
        tr $ (td $ text "Needed (= Maximum - Allocated)") *> (td $ text $ printVec needV)
        tr $ (td $ text "Available") *> (td $ text $ printVec availV)
        tr $ (td $ text "Test Allocate (= Available - Needed)") *> (td $ text $ printVec testAllocV)
  if canAlloc
    then do
      let availV' = zipWith (+) allocV availV
      table $ m *> (tr $ td ! colspan "2" $ span ! className "alloc" $ text "Can allocate.")
      _ /\ s /\ _ <- handleProc $ allocM /\ maxiM /\ availV' /\ unit
      pure $ true /\ s /\ unit
    else do
      table $ m *> (tr $ td ! colspan "2" $ span ! className "unalloc" $ text "Cannot allocate.")
      isSafe /\ (allocM' /\ maxiM' /\ availV' /\ _) /\ _ <- handleProc $ allocM /\ maxiM /\ availV /\ unit
      pure $ isSafe /\ (Cons allocV allocM' /\ Cons maxiV maxiM' /\ availV' /\ unit) /\ unit
handleProc s = pure $ false /\ s /\ unit  -- FIXME: should be never reached

handleConstr :: forall e. Tuple3 IntMat IntMat IntVec -> Markup e
handleConstr s@(allocM /\ maxiM /\ availV /\ _) = do
  h2 $ text $ "Checking for " <> printMat allocM
  isSafe /\ s'@(alloc /\ _ /\ _ /\ _) /\ _ <- handleProc s
  unless (not isSafe || null alloc) $ handleConstr s'

solve :: String -> String -> String -> String
solve allocM maxiM availV = render $ handleConstr $ readIntMat allocM /\ readIntMat maxiM /\ readIntVec availV /\ unit
