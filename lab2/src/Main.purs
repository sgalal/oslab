module Main (Block(..), allocate, initialize, retrieve) where

import Data.List (List(..), fromFoldable, toUnfoldable)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toNullable)
import Prelude (map, pure, (+), (-), (<<<), (==), (>))

data Block = Idle { len :: Int } | Allocated { len :: Int, pid :: Int }

allocate_aux :: Int -> Int -> List Block -> Maybe (List Block)
allocate_aux _ _ Nil = Nothing
allocate_aux p l (Cons (Idle { len : x }) xs)
  | x == l = Just (Cons (Allocated { len : x, pid : p }) xs)
  | x >  l = Just (Cons (Allocated { len : l, pid : p }) (Cons (Idle { len : x - l }) xs))
allocate_aux p l (Cons x xs) = map (Cons x) (allocate_aux p l xs)

allocate :: Int -> Int -> Array Block -> Nullable (Array Block)
allocate p l = toNullable <<< map toUnfoldable <<< allocate_aux p l <<< fromFoldable

retrieve_aux :: Int -> List Block -> Maybe (List Block)
retrieve_aux _ Nil = Nothing
retrieve_aux p (Cons (Idle { len : x }) (Cons (Allocated { len : y, pid : p' }) (Cons (Idle { len : z }) xs))) | p == p' = Just (Cons (Idle { len : x + y + z }) xs)
retrieve_aux p (Cons (Idle { len : x }) (Cons (Allocated { len : y, pid : p' }) xs)) | p == p' = Just (Cons (Idle { len : x + y }) xs)
retrieve_aux p (Cons (Allocated { len : x, pid : p' }) (Cons (Idle { len : y }) xs)) | p == p' = Just (Cons (Idle { len : x + y }) xs)
retrieve_aux p (Cons (Allocated { len : x, pid : p' }) xs) | p == p' = Just (Cons (Idle { len : x }) xs)
retrieve_aux p (Cons x xs) = map (Cons x) (retrieve_aux p xs)

retrieve :: Int -> Array Block -> Nullable (Array Block)
retrieve p = toNullable <<< map toUnfoldable <<< retrieve_aux p <<< fromFoldable

initialize :: Int -> Array Block
initialize l = pure (Idle { len : l })
