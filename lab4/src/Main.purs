module Banker (main, alloc, maxi, avail) where

import Data.Int (fromString)
import Data.Maybe
import Data.List
import Data.String as S
import Prelude
import Simple.JSON as JSON

type IntVec = List Int

type IntMat = List IntVec

type ProcStat =
  { getAllocV     :: IntVec
  , getMaxiV      :: IntVec
  , getNeedV      :: IntVec
  , getTestAllocV :: IntVec
  , getCanAlloc   :: Boolean
  }

type ConstrStat =
  { getAllocM   :: IntMat
  , getMaxiM    :: IntMat
  , getAvailV   :: IntVec
  , getProcStat :: List ProcStat
  , getIsSafe   :: Boolean
  }

readIntVec :: String -> IntVec
readIntVec = map (fromMaybe 0) <<< fromFoldable <<< map fromString <<< S.split (S.Pattern " ")
-- FIXME: fromMaybe 0

readIntMat :: String -> IntMat
readIntMat = fromFoldable <<< map readIntVec <<< S.split (S.Pattern " ")

type HandleProcHelper =
  { alloc :: IntMat
  , maxi :: IntMat
  , avail :: IntVec
  }

handleProc :: HandleProcHelper -> { isSafe :: Boolean, procStats :: List ProcStat, ret :: HandleProcHelper }
handleProc s@{ alloc : Nil, maxi : Nil } = { isSafe : false, procStats : Nil, ret : s }
handleProc { alloc : Cons allocV allocM, maxi : Cons maxiV maxiM, avail : availV } =
  let needV      = zipWith (-) maxiV allocV
      testAllocV = zipWith (-) availV needV
      canAlloc   = all (\nn -> nn >= 0) testAllocV
      x =
        { getAllocV     : allocV
        , getMaxiV      : maxiV
        , getNeedV      : needV
        , getTestAllocV : testAllocV
        , getCanAlloc   : canAlloc
        }
   in if canAlloc
    then
      let availV'  = zipWith (+) allocV availV
          { isSafe : _, procStats : xs, ret : s } = handleProc { alloc : allocM, maxi : maxiM, avail : availV' }
       in { isSafe : true, procStats : Cons x xs, ret : s }
    else
      let { isSafe : isSafe, procStats : xs, ret : { alloc : allocM', maxi : maxiM', avail : availV' } } =
            handleProc { alloc : allocM, maxi : maxiM, avail : availV }
       in { isSafe : isSafe, procStats : Cons x xs, ret : { alloc : Cons allocV allocM', maxi : Cons maxiV maxiM', avail : availV' } }
handleProc s = { isSafe : false, procStats : Nil, ret : s }

handleConstr :: HandleProcHelper -> List ConstrStat
handleConstr s@{ alloc : allocM, maxi : maxiM, avail : availV } =
  let { isSafe : isSafe, procStats : xs, ret : s'@{ alloc : aaaaaa } } = handleProc s
      x =
        { getAllocM   : allocM
        , getMaxiM    : maxiM
        , getAvailV   : availV
        , getProcStat : xs
        , getIsSafe   : isSafe
        }
   in if isSafe && not (null aaaaaa)
    then Cons x $ handleConstr s'
    else pure x

banker :: String -> String -> String -> List ConstrStat
banker allocM maxiM availV = handleConstr { alloc : readIntMat allocM, maxi : readIntMat maxiM, avail : readIntVec availV }

transfa :: ProcStat -> { allocV :: Array Int
                         , maxiV :: Array Int
                         , needV :: Array Int
                         , testAllocV :: Array Int
                         , canAlloc :: Boolean
                         }
transfa { getAllocV : d -- : List Int
                         , getMaxiV : e -- : List Int
                         , getNeedV : f -- : List Int
                         , getTestAllocV : g -- : List Int
                         , getCanAlloc : h -- : Boolean
                         } = { allocV : toUnfoldable d -- : List Int
                         , maxiV : toUnfoldable e -- : List Int
                         , needV : toUnfoldable f -- : List Int
                         , testAllocV : toUnfoldable g -- : List Int
                         , canAlloc : h -- : Boolean
                         }

transf :: ConstrStat -> { allocM :: Array (Array Int)
        , maxiM :: Array (Array Int)
        , availV :: Array Int
        , procStat :: Array { allocV :: Array Int
                         , maxiV :: Array Int
                         , needV :: Array Int
                         , testAllocV :: Array Int
                         , canAlloc :: Boolean
                         }
        , isSafe :: Boolean
        }
transf { getAllocM : a -- : List (List Int)
        , getMaxiM : b -- : List (List Int)
        , getAvailV : c -- : List Int
        , getProcStat : e
        , getIsSafe : i -- : Boolean
        }
      = { allocM : toUnfoldable $ map toUnfoldable $ a -- : List (List Int)
        , maxiM : toUnfoldable $ map toUnfoldable $ b -- : List (List Int)
        , availV : toUnfoldable c -- : List Int
        , procStat : toUnfoldable $ map transfa e
        , isSafe : i -- : Boolean
        }


main alloc maxi avail = JSON.writeJSON $ (toUnfoldable :: forall a. List a -> Array a) $ map transf $ banker alloc maxi avail

alloc = "0 0 1 4\n1 4 3 2\n1 3 5 4\n1 0 0 0"
maxi = "0 6 5 6\n1 9 4 2\n1 3 5 6\n1 7 5 0"
avail = "1 5 2 0"
