data LTree a = Leaf a | LBranch (LTree a) (LTree a) deriving (Show)

instance Functor LTree where
  fmap f (LBranch left right) = LBranch (fmap f left) (fmap f right)
  fmap f (Leaf x) = Leaf (f x)

(<**>) = flip (<*>)

instance Applicative LTree where
  pure = Leaf
  (Leaf f) <*> rhs = fmap f rhs
  (LBranch left right) <*> (Leaf y) = LBranch (left <*> (Leaf y)) (right <*> (Leaf y))
  lhs <*> (LBranch left right) = LBranch (left <**> lhs) (right <**> lhs)

-- let a = LBranch (LBranch (Leaf 1) (Leaf 2)) (Leaf 3)
-- (+) <$> a <*> Leaf 0
---- LBranch (LBranch (Leaf 1) (Leaf 2)) (Leaf 3)
-- (+) <$> Leaf 0 <*> a
---- LBranch (LBranch (Leaf 1) (Leaf 2)) (Leaf 3)
-- (+) <$> a <*> LBranch (Leaf 10) (Leaf 20)
---- LBranch (LBranch (LBranch (Leaf 11) (Leaf 12)) (Leaf 13)) (LBranch (LBranch (Leaf 21) (Leaf 22)) (Leaf 23))
-- (+) <$> LBranch (Leaf 10) (Leaf 20) <*> a
---- LBranch (LBranch (LBranch (Leaf 11) (Leaf 12)) (Leaf 13)) (LBranch (LBranch (Leaf 21) (Leaf 22)) (Leaf 23))