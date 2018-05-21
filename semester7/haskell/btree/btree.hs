module BinaryTree (BTree(Empty, Branch)) where

import Prelude hiding ((<=), (^))
import Data.Char
import Data.Functor
import Control.Applicative

-- Derive Eq and Show typeclasses so we can compare and print BTree instances.
data BTree a = Empty | Branch a (BTree a) (BTree a) deriving (Eq, Show)

depth :: BTree a -> Int
-- Depth of empty tree is 0.
depth (Empty) = 0
-- Depth of a tree is 1 (root) + max value of depths of left & right subtrees.
depth (Branch _ left right) = 1 + max (depth left) (depth right)

leftmost :: BTree a -> a
leftmost (Empty) = error "Empty has no value"
-- If we have no left child, we're done.
leftmost (Branch a Empty _) = a
-- Otherwise, just go to the left subtree.
leftmost (Branch _ left _) = leftmost left

-- The same as preorder traversal, basically.
treewalk_depth :: BTree a -> [a]
treewalk_depth (Empty) = []
-- [current node, left traversal, right traversal]
treewalk_depth (Branch a left right) = a : treewalk_depth left ++ treewalk_depth right

-- Auxiliary function which concatenates width traversals of 2 subtrees.
-- I would like to use `zip` here, but it discards the leftover of longer list,
-- which we need to use.
concatLevels :: [[a]] -> [[a]] -> [[a]]
concatLevels [] [] = []
concatLevels xs [] = xs
concatLevels [] xs = xs
concatLevels (x:xs) (y:ys) = [x ++ y] ++ (concatLevels xs ys)

levelWiseTraversal :: BTree a -> [[a]]
levelWiseTraversal (Empty) = []
levelWiseTraversal (Branch a left right) =
    [[a]] ++ concatLevels (levelWiseTraversal left) (levelWiseTraversal right)

treewalk_width :: BTree a -> [a]
treewalk_width (Empty) = error "Empty has no value"
treewalk_width root = (concat . levelWiseTraversal) root

chop_tree :: BTree a -> Int -> BTree a
-- We've chopped it.
chop_tree _ 0 = Empty
-- Nothing to chop.
chop_tree Empty _ = Empty
-- Allow current root and chop subtrees.
chop_tree (Branch x left right) k = Branch x (chop_tree left (k-1)) (chop_tree right (k-1))

-- Auxiliary function to compare 2 trees elementByElement.
elementByElementCompare :: (Eq a) => BTree a -> BTree a -> Bool
elementByElementCompare Empty Empty = True
elementByElementCompare _ Empty = False
elementByElementCompare Empty _ = False
-- Compare roots and subtrees.
elementByElementCompare (Branch rootl leftl rightl) (Branch rootr leftr rightr) =
    rootl == rootr &&
    elementByElementCompare leftl rightr &&
    elementByElementCompare rightl leftr

is_symmetric :: (Eq a) => BTree a -> Bool
is_symmetric Empty = True
is_symmetric (Branch x left right) = elementByElementCompare left right

-- Add some invariance to elementByElementCompare.
equal_unordered :: (Eq a) => BTree a -> BTree a -> Bool
equal_unordered Empty Empty = True
equal_unordered _ Empty = False
equal_unordered Empty _ = False
equal_unordered (Branch rootl leftl rightl) (Branch rootr leftr rightr) =
    rootl == rootr &&
    ((elementByElementCompare leftl leftr && elementByElementCompare rightl rightr) ||
    (elementByElementCompare leftl rightr && elementByElementCompare rightl leftr))

(<=) :: BTree a -> BTree a -> BTree a
-- Initial fixity of `<=` operator
infixl 4 <=
-- Don't change the structure of a lhs tree.
Empty <= x = Empty
-- Nothing on the right side.
x <= Empty = x
-- Replace root value and continue to subtrees.
Branch _ leftl rightl <= Branch rootr leftr rightr = Branch rootr (leftl <= leftr) (rightl <= rightr)

(^) :: BTree a -> BTree a -> BTree a
-- Initial fixity of `^` operator
infixr 8 ^
-- Nothing on the right side.
x ^ Empty = x
-- We're at the right spot, inject the right argument.
Empty ^ x = x
-- Continue to look for empty leaves.
Branch root left right ^ x = Branch root (left ^ x) (right ^ x)
