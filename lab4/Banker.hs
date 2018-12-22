{-# LANGUAGE DeriveGeneric #-}

import Data.Aeson
import Data.ByteString.Lazy (ByteString)
import GHC.Generics

type IntVec = [Int]
type IntMat = [IntVec]

data ProcStat = ProcStat
  { getAllocV     :: IntVec
  , getMaxiV      :: IntVec
  , getNeedV      :: IntVec
  , getTestAllocV :: IntVec
  , getCanAlloc   :: Bool
  } deriving (Generic, Show)
instance ToJSON ProcStat

data ConstrStat = ConstrStat
  { getAllocM   :: IntMat
  , getMaxiM    :: IntMat
  , getAvailV   :: IntVec
  , getProcStat :: [ProcStat]
  , getIsSafe   :: Bool
  } deriving (Generic, Show)
instance ToJSON ConstrStat

readIntVec :: String -> IntVec
readIntVec = fmap read . words

readIntMat :: String -> IntMat
readIntMat = fmap readIntVec . lines

handleProc :: (IntMat, IntMat, IntVec) -> (Bool, [ProcStat], (IntMat, IntMat, IntVec))
handleProc s@([],[],_) = (False, [], s)
handleProc (allocV:allocM,maxiV:maxiM,availV) =
  let needV      = zipWith (-) maxiV allocV
      testAllocV = zipWith (-) availV needV
      canAlloc   = all (>= 0) testAllocV
      x = ProcStat
        { getAllocV     = allocV
        , getMaxiV      = maxiV
        , getNeedV      = needV
        , getTestAllocV = testAllocV
        , getCanAlloc   = canAlloc
        }
   in if canAlloc
    then
      let availV'  = zipWith (+) allocV availV
          (_,xs,s) = handleProc (allocM, maxiM, availV')
       in (True, x:xs, s)
    else
      let (isSafe,xs,(allocM',maxiM',availV')) = handleProc (allocM, maxiM, availV)
       in (isSafe, x:xs, (allocV:allocM', maxiV:maxiM', availV'))

handleConstr :: (IntMat, IntMat, IntVec) -> [ConstrStat]
handleConstr s@(allocM,maxiM,availV) =
  let (isSafe,xs,s') = handleProc s
      x = ConstrStat
        { getAllocM   = allocM
        , getMaxiM    = maxiM
        , getAvailV   = availV
        , getProcStat = xs
        , getIsSafe   = isSafe
        }
   in if isSafe && not (null $ (\(a,_,_) -> a) s')
    then x : handleConstr s'
    else pure x

banker :: String -> String -> String -> ByteString
banker allocM maxiM availV = encode $ handleConstr (readIntMat allocM, readIntMat maxiM, readIntVec availV)

main :: IO ()
main = print $ banker alloc maxi avail

alloc = "0 0 1 4\n1 4 3 2\n1 3 5 4\n1 0 0 0"
maxi = "0 6 5 6\n1 9 4 2\n1 3 5 6\n1 7 5 0"
avail = "1 5 2 0"
