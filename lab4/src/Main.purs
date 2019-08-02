module Main (solve) where

import Control.Monad.Free (Free)
import Data.Int (fromString)
import Data.List (List(..), all, fromFoldable, intercalate, null, zipWith)
import Data.Maybe (fromMaybe)
import Data.String as S
import Data.Tuple.Nested
import Prelude (bind, const, discard, map, pure, show, ($), (+), (-), (<<<), (<>), (>=))
import Text.Smolder.HTML (h2, h3, p, span)
import Text.Smolder.HTML.Attributes (className, title)
import Text.Smolder.Markup (Markup, MarkupM, text, (!))
import Text.Smolder.Renderer.String (render)

type IntVec = List Int
type IntMat = List IntVec

readIntVec :: String -> IntVec
readIntVec = fromFoldable <<< map (fromMaybe 0 <<< fromString) <<< S.split (S.Pattern " ")

readIntMat :: String -> IntMat
readIntMat = fromFoldable <<< map readIntVec <<< S.split (S.Pattern "\n")

showIntVec :: IntVec -> String
showIntVec xs = "[" <> intercalate " " (map show xs) <> "]"

showIntMat :: IntMat -> String
showIntMat xs = "[" <> intercalate " " (map showIntVec xs) <> "]"

handleProc :: forall e. IntMat -> IntMat -> IntVec -> Free (MarkupM e) (Tuple4 Boolean IntMat IntMat IntVec)
handleProc (Cons allocV allocM) (Cons maxiV maxiM) availV = do
  h3 $ text ("Checking " <> showIntVec allocV)
  p $ span (text "Maximum:") <> span (text $ showIntVec maxiV)
  p $ (span ! title "Maximum - Allocation" $ text "Need:") <> span (text $ showIntVec needV)
  p $ span (text "Available:") <> span (text $ showIntVec availV)
  p $ (span ! title "Available - Need" $ text "Test Allocate:") <> span (text $ showIntVec testAllocV)
  if canAlloc
    then p ! className "alloc" $ text "Can allocate."
    else p ! className "unalloc" $ text "Cannot allocate."
  if canAlloc
    then do
      let availV' = zipWith (+) allocV availV
      map (\res -> const true `over1` res) $ handleProc allocM maxiM availV'
    else do
      map (\res -> Cons allocV `over2` (Cons maxiV `over3` res)) $ handleProc allocM maxiM availV
  where
  needV      = zipWith (-) maxiV allocV
  testAllocV = zipWith (-) availV needV
  canAlloc   = all (\n -> n >= 0) testAllocV
handleProc _ _ x = pure $ tuple4 false Nil Nil x

handleConstr :: forall e. IntMat -> IntMat -> IntVec -> Markup e
handleConstr allocM maxiM availV = do
  h2 $ text $ "Checking " <> showIntMat allocM
  isSafe /\ res@(allocM' /\ _) <- handleProc allocM maxiM availV
  case isSafe, null allocM' of
    true , false -> uncurry3 handleConstr res
    false, _     -> h2 $ text "Not safe."
    true , true  -> h2 $ text "Safe."

solve :: String -> String -> String -> String
solve allocM maxiM availV = render $ handleConstr (readIntMat allocM) (readIntMat maxiM) (readIntVec availV)
