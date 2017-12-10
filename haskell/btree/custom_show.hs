module CustomShow where
import Data.List
import Text.Printf

data BTree a = Empty | Branch a (BTree a) (BTree a)

instance (Show a) => Show (BTree a) where
  show Empty = "*"
  show t =
    let treeInfo = subtreeWidth t 0
        levels = levelWiseWalk treeInfo []
        res = intercalate "\n" levels
    in res

-- (repr, width, margin)
type TShowable = (String, Int, Int)
-- tree -> margin -> tree [2]
subtreeWidth :: (Show a) => BTree a -> Int -> BTree TShowable
subtreeWidth Empty margin = Branch ("* ", 2, margin) Empty Empty
subtreeWidth (Branch x left right) margin =
    let leftTree = subtreeWidth left margin
        xStr = show x ++ " "
        currentWidth = case leftTree of
            (Branch (_, leftWidth, _) _ _) -> max (length xStr) leftWidth
        rightTree = subtreeWidth right (margin + currentWidth)
        xWidth = case rightTree of
          (Branch (_, rightWidth, _) _ _) -> currentWidth + rightWidth
    in Branch (xStr, xWidth, margin) leftTree rightTree

-- Fill the traversal level by level.
-- tree -> current level -> levels from current to the bottom -> modified levels from current to the bottom
levelWiseWalk :: BTree TShowable -> [String] -> [String]
levelWiseWalk Empty levels = levels
levelWiseWalk (Branch (xStr, xWidth, xMargin) left right) levels =
    let (currentLevel, nextLevels) = case levels of
            (x:xs) -> (x, xs)
            _ -> ("", [])
        leftMargin = max (xMargin - (length currentLevel)) 0
        currentLevelModified = currentLevel ++ printf "%*s%s" leftMargin "" xStr
        nextLevelsModified = levelWiseWalk right (levelWiseWalk left nextLevels)
    in currentLevelModified : nextLevelsModified

-- putStrLn $ show $ Branch 1 Empty (Branch 2 (Branch 3 Empty Empty) (Branch 4 Empty Empty))
---- 1
---- * 2
----   3   4
----   * * * *
-- putStrLn $ show $ Branch 1 (Branch 2 (Branch 3 Empty (Branch 4 Empty Empty)) Empty) (Branch 5 Empty Empty)
---- 1
---- 2       5
---- 3     * * *
---- * 4
----   * *
-- putStrLn $ show $ Branch 1 (Branch 2 (Branch 4 Empty Empty) Empty) (Branch 3 (Branch 5 (Branch 7 Empty Empty) Empty) (Branch 6 (Branch 8 (Branch 10 Empty Empty) (Branch 11 Empty Empty)) (Branch 9 Empty Empty)))
---- 1
---- 2     3
---- 4   * 5     6
---- * *   7   * 8         9
----       * *   10   11   * *
----             *  * *  *
-- putStrLn $ show $ Branch 1 Empty (Branch 2 Empty (Branch 3 (Branch 4 (Branch 5 (Branch 6 Empty (Branch 7 Empty Empty)) Empty) Empty) Empty))
---- 1
---- * 2
----   * 3
----     4         *
----     5       *
----     6     *
----     * 7
----       * *
