module BinaryTreeApplicative where
import BinaryTree
import BinaryTreeFunctor

instance Applicative BTree where
  pure x = Branch x Empty Empty
  Empty <*> _ = Empty
  (Branch _ _ _) <*> Empty = Empty
  (Branch f fleft fright) <*> (Branch y left right) = Branch (f y) (fleft <*> left) (fright <*> right)

-- let a = Branch 1 (Branch 2 (Branch 3 Empty Empty) Empty) (Branch 4 Empty Empty)
-- let b = Branch 1 (Branch 4 Empty Empty) (Branch 2 Empty (Branch 3 Empty Empty))
-- let c = Branch 1 (Branch 2 (Branch 3 Empty Empty) (Branch 4 Empty Empty)) Empty
-- (+) <$> a <*> b
-- (,) <$> a <*> c
