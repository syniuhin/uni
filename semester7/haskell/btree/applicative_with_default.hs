-- In order to properly use this one, run ghci insite btree folder and load like this:
-- :load applicative_with_default.hs functor.hs btree.hs
-- Then, when running <**>, explicitly specify output type, because we can't specify
-- Monoid for all Num instances, so I narrowed it to the Int. There's an example
-- in the end of this file, which shows how to run it properly.
module BinaryTreeApplicativeWithDefault where
import BinaryTree
import BinaryTreeFunctor

instance Monoid Int where
  mempty = 0
  mappend = (+)

class Functor f => ApplicativeOnMonoid f where
  pure :: x -> f x
  (<**>) :: (Monoid a) => f (a -> a) -> f a -> f a

instance ApplicativeOnMonoid BTree where
  pure x = Branch x Empty Empty
  Empty <**> Empty = Empty
  Empty <**> (Branch x left right) = Branch x left right
  (Branch f fleft fright) <**> Empty = Branch (f mempty) (fleft <**> Empty) (fright <**> Empty)
  (Branch f fleft fright) <**> (Branch y left right) = Branch (f y) (fleft <**> left) (fright <**> right)

-- let a = Branch 1 (Branch 2 (Branch 3 Empty Empty) Empty) (Branch 4 Empty Empty)
-- let b = Branch 1 (Branch 4 Empty Empty) (Branch 2 Empty (Branch 3 Empty Empty))
-- let c = Branch 1 (Branch 2 (Branch 3 Empty Empty) (Branch 4 Empty Empty)) Empty
-- (((+) <$> a) :: BTree (Int -> Int)) <**> b
---- Branch 2 (Branch 6 (Branch 3 Empty Empty) Empty) (Branch 6 Empty (Branch 3 Empty Empty))
