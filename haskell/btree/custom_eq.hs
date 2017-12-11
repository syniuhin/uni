module CustomEq where

data BTree a = Empty | Branch a (BTree a) (BTree a)

instance (Eq a) => Eq (BTree a) where
  Empty == Empty = True
  Empty == _ = False
  _ == Empty = False
  (Branch leftX leftLeft leftRight) == (Branch rightX rightLeft rightRight) = leftX == rightX &&
      ((leftLeft == rightLeft && leftRight == rightRight) || (leftRight == rightLeft && leftLeft == rightRight))
  x /= y = not (x == y)

-- let a = Branch 1 (Branch 2 (Branch 3 Empty Empty) Empty) (Branch 4 Empty Empty)
-- let b = Branch 1 (Branch 4 Empty Empty) (Branch 2 Empty (Branch 3 Empty Empty))
-- let c = Branch 1 (Branch 2 (Branch 3 Empty Empty) (Branch 4 Empty Empty)) Empty
-- a == b
-- a == c
