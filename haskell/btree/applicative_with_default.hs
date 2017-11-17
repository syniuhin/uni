module BinaryTreeApplicativeWithDefault where
import Prelude hiding ((<*>))
import BinaryTree
import BinaryTreeFunctor
import Data.Monoid

instance Monoid Int where
  mempty = 0
  mappend = (+)

class Functor f => ApplicativeOnMonoid f where
  pure :: (Monoid x) => x -> f x
  (<*>) :: (Monoid a) => f (a -> b) -> f a -> f b

instance ApplicativeOnMonoid BTree where
  pure x = Branch x Empty Empty
  Empty <*> Empty = Empty
  Empty <*> (Branch x left right) = Empty
  (Branch f fleft fright) <*> Empty = Branch (f mempty) (fleft <*> Empty) (fright <*> Empty)
  (Branch f fleft fright) <*> (Branch y left right) = Branch (f y) (fleft <*> left) (fright <*> right)

-- let a = Branch 1 (Branch 2 (Branch 3 Empty Empty) Empty) (Branch 4 Empty Empty)
-- let b = Branch 1 (Branch 4 Empty Empty) (Branch 2 Empty (Branch 3 Empty Empty))
-- let c = Branch 1 (Branch 2 (Branch 3 Empty Empty) (Branch 4 Empty Empty)) Empty
-- (+) <$> a <*> b
---- Branch 2 (Branch 6 (Branch 3 Empty Empty) Empty) (Branch 6 Empty (Branch 3 Empty Empty))