-- ========== Functors, Bifunctors, Arrows, Monads
-- =================================================
{-# OPTIONS_GHC -fno-warn-tabs #-}
{-# LANGUAGE FlexibleInstances #-}

import Control.Monad.Trans.State
import Data.Ratio

-- Kleisli arrow
-- Left identity: return >=> g	= g
-- Right identity:	f >=> return = f
-- Associativity: (f >=> g) >=> h = f >=> (g >=> h)
class Applicative k => Kleisli k where
	(>=>)::(a -> k b) -> (b -> k c) -> (a -> k c)
	(<=<)::(b -> k c) -> (a -> k b) -> (a -> k c)
	return':: a->k a
	(<=<) = flip (>=>)
	(>=>) = flip (<=<)
	-- {-# MINIMAL (<=<) | (>=>) #-}

infixl 9 >=>
infixl 9 <=<

instance Kleisli [] where
	f >=> g 	= concat . (map g) . f
	return' a 	= [a]

-- instance Kleisli  ((,)String) where
-- 	return' a = ("", a)
-- 	f >=> g   = \x -> let (sy, y) = f x;
-- 						  (sz, z) = g y
-- 					  in (sy ++ sz, z)

-- 31
instance Monoid m => Kleisli ((,) (m)) where
	return' a = (mempty, a)
	f >=> g   = \x -> let (sy, y) = f x;
						  (sz, z) = g y
                      in (mappend sz sy, z)

-- logging:: (a->a) -> String -> (a-> (String, a))
-- logging f descr val = (descr, f val)

logging :: (Monoid m) => (a -> b) -> m -> (a -> (m, b))
logging f descr val = (descr, f val)

f = (+5)
g = (*4)

f_log = logging f "Add 5;"
g_log = logging g "Multiply by 4;"

x = 3
y = f . g $ x
(log_y2, y2) = f_log <=< g_log $ x

-- 32 ??
-- instance Kleisli k => Monad k where
--     ma >>= f = fmap f ma

-- 33 ??
-- instance Monad m => Kleisli m where
--     f >=> g = fmap (\x -> f . g $ x)

-- 34
class Applicative f => Flatten f where
    flatten :: (a -> f (f b)) -> (a -> f b)

instance Flatten [] where
    flatten f = \x ->
        let y = f x
            z = case y of
              [] -> []
              [xs] -> xs
        in z

wrapp :: Int -> [[Int]]
wrapp x
    | x == 10 = []
    | otherwise = [[x]]

instance Flatten Maybe where
    flatten f = \x ->
        let y = f x
            z = case y of
                Nothing -> Nothing
                Just x -> x
        in z

veryMaybe :: Int -> Maybe (Maybe Int)
veryMaybe x
    | x == 10 = Nothing
    | x == 11 = Just Nothing
    | otherwise = Just (Just (x * 2))

-- 35
-- instance Flatten f => Monad f where
--     ma >>= f =

-- Maybe monad - Parents example
data Person = Joe | Jim | Linda | Keysi | Fedor | Anya deriving (Show, Eq)
persons = [Joe, Jim, Linda, Keysi, Fedor, Anya]

father :: Person -> Maybe Person
mother :: Person -> Maybe Person

father Joe = Just Jim
father Jim = Just Fedor
father Keysi = Just Fedor
father Linda = Just Jim
father _ = Nothing
mother Linda = Just Keysi
mother Keysi = Just Anya
mother _ = Nothing

-- 37
parents :: Person -> [Person]
parents p =
    case (father p, mother p) of
        (Nothing, Nothing) -> []
        (Just f, Nothing) -> [f]
        (Nothing, Just m) -> [m]
        (Just f, Just m) -> [f, m]

allGrandparents :: Person -> [Person]
allGrandparents p = concat (map parents (parents p))

-- 38
traverseParents :: [Person -> Maybe Person] -> Person -> Maybe Person
traverseParents [] _ = Nothing
traverseParents [f] p = f p
traverseParents (f:fs) p = f p >>= traverseParents fs

-- 39
-- newtype Prob a = Prob { getProb :: [(a,Rational)] } deriving Show
-- instance Functor Prob where
--     fmap f (Prob xs) = Prob $ map (\(x,p) -> (f x,p)) xs

-- instance Monad Prob where
--     return x = Prob [(x,1%1)]
--     m >>= f = flatten (fmap f m)
--     fail _ = Prob []
