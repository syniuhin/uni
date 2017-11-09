module BinaryTreeApplicativeWithDefault where
import BinaryTree
import BinaryTreeFunctor
import Data.Monoid

-- WIP
instance Monoid m => Applicative (BTree m) where
  pure x = Branch x Empty Empty
  Empty <*> Empty = Empty
  Empty <*> right = right
  (Branch f fleft fright) <*> Empty = Branch (f mempty) (fleft <*> Empty) (fright <*> Empty)
  (Branch f fleft fright) <*> (Branch y left right) = Branch (f y) (fleft <*> left) (fright <*> right)
