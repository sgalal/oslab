module Main (solve) where

import Control.Monad.Free (Free)
import Data.Int (fromString)
import Data.List (List(..), all, fromFoldable, intercalate, null, zipWith)
import Data.Maybe (fromMaybe)
import Data.String as S
import Data.Tuple.Nested
import Prelude (bind, const, discard, map, pure, show, ($), (*>), (+), (-), (<<<), (<>), (>=))
import Text.Smolder.HTML (h2, span, table, td, tr)
import Text.Smolder.HTML.Attributes (className, colspan)
import Text.Smolder.Markup (Markup, MarkupM, text, (!))
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
handleProc (Cons allocV allocM) (Cons maxiV maxiM) availV =
  let needV      = zipWith (-) maxiV allocV
      testAllocV = zipWith (-) availV needV
      canAlloc   = all (\n -> n >= 0) testAllocV
      m          = do
        tr $ (td $ text "Allocated")                            *> (td $ text $ printVec allocV)
        tr $ (td $ text "Maximum")                              *> (td $ text $ printVec maxiV)
        tr $ (td $ text "Needed (= Maximum - Allocated)")       *> (td $ text $ printVec needV)
        tr $ (td $ text "Available")                            *> (td $ text $ printVec availV)
        tr $ (td $ text "Test Allocate (= Available - Needed)") *> (td $ text $ printVec testAllocV)
  in if canAlloc
    then do
      let availV' = zipWith (+) allocV availV
      table $ m *> (tr $ td ! colspan "2" $ span ! className "alloc" $ text "Can allocate.")
      map (\res -> const true `over1` res) $ handleProc allocM maxiM availV'
    else do
      table $ m *> (tr $ td ! colspan "2" $ span ! className "unalloc" $ text "Cannot allocate.")
      map (\res -> Cons allocV `over2` (Cons maxiV `over3` res)) $ handleProc allocM maxiM availV
handleProc _ _ x = pure $ tuple4 false Nil Nil x

handleConstr :: forall e. IntMat -> IntMat -> IntVec -> Markup e
handleConstr allocM maxiM availV = do
  h2 $ text $ "Checking for " <> printMat allocM
  isSafe /\ res@(allocM' /\ _) <- handleProc allocM maxiM availV
  case isSafe, null allocM' of
    true , false -> uncurry3 handleConstr res
    false, _     -> h2 $ text "Not safe."
    true , true  -> h2 $ text "Safe."

solve :: String -> String -> String -> String
solve allocM maxiM availV = render $ handleConstr (readIntMat allocM) (readIntMat maxiM) (readIntVec availV)
