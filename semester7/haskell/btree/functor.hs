module BinaryTreeFunctor where
import BinaryTree

instance Functor BTree where
  fmap _ Empty = Empty
  fmap f (Branch x left right) = Branch (f x) (fmap f left) (fmap f right)
