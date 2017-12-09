module CustomShow where
import Data.List
import Text.Printf

data BTree a = Empty | Branch a (BTree a) (BTree a)

instance (Show a) => Show (BTree a) where
  show Empty = "*"
  show t = intercalate "\n" (levelWiseTraversal $ subtreeWidth t)

-- (repr, width, margin)
type TShowable = (String, Int, Int)

subtreeWidth :: (Show a) => BTree a -> Int -> BTree TShowable
subtreeWidth Empty margin = Branch ("*", 2, margin) Empty Empty
subtreeWidth (Branch x left right) margin =
    let leftTree = subtreeWidth left margin
        rightTree = case leftTree of
          (Branch (_, width, margin)) -> subtreeWidth right (margin + width)
        xwidth = case (leftTree, rightTree) of
          (Branch (_, leftWidth, leftMargin) _ _, Branch (_, rightWidth) _ _) -> max (1 + (length $ show x)) (leftWidth + rightWidth)
        res = (Branch (show x ++ " ", xwidth) leftTree rightTree)
    in res

concatLevels :: [String] -> [String] -> [String]
concatLevels [] [] = []
concatLevels xs [] = xs
concatLevels [] xs = xs
concatLevels (x:xs) (y:ys) =
    [x ++ y] ++ (concatLevels xs ys)

levelWiseTraversal :: BTree TShowable -> [String]
levelWiseTraversal (Empty) = []
levelWiseTraversal (Branch (x, xw) left right) =
    [printf ("%-" ++ (show xw) ++ "s") x] ++ concatLevels (levelWiseTraversal left) (levelWiseTraversal right)

-- putStrLn $ show $ Branch 1 Empty (Branch 2 (Branch 3 Empty Empty) (Branch 4 Empty Empty))