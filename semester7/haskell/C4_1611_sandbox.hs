-- ========== Functors, Bifunctors, Arrows, Monads
-- =================================================
{-# OPTIONS_GHC -fno-warn-tabs #-}
{-# LANGUAGE FlexibleInstances #-}

import Control.Monad.Trans.State

-- Kleisli arrow
-- Left identity: return >=> g	= g
-- Right identity:	f >=> return = f
-- Associativity: (f >=> g) >=> h = f >=> (g >=> h)
class Kleisli k where
	(>=>)::(a -> k b) -> (b -> k c) -> (a -> k c)
	(<=<)::(b -> k c) -> (a -> k b) -> (a -> k c)
	return':: a->k a
	(<=<) = flip (>=>)
	(>=>) = flip (<=<)


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

-- Kleisli arrow based on monoids

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


maternalGrandfather :: Person -> Maybe Person
maternalGrandfather p =
    case mother p of
        Nothing -> Nothing
        Just mom -> father mom

bothGrandfathers :: Person -> Maybe (Person, Person)
bothGrandfathers p =
    case father p of
        Nothing -> Nothing
        Just dad ->
            case father dad of
                Nothing -> Nothing
                Just gf1 ->                          -- found first grandfather
                    case mother p of
                        Nothing -> Nothing
                        Just mom ->
                            case father mom of
                                Nothing -> Nothing
                                Just gf2 ->          -- found second grandfather
                                    Just (gf1, gf2)


bothGrandfathersII p = do {
        dad <- father p;
        gf1 <- father dad;
        mom <- mother p;
        gf2 <- father mom;
        return (gf1, gf2);
      }

--bothGrandfathersIII:: Person ->Maybe (Person, Person)
bothGrandfathersIII p =
    (father p >>= father)


bothGrandfathersIV p =
       (father p >>= father) >>=
           (\gf1 -> (mother p >>= father) >>=
               (\gf2 -> return (gf1,gf2) ))

bothGrandfathers' p = do
    f <- father p
    gf1 <- father f
    gf2 <- (mother p >>= father)
    return (gf1,gf2)




-- Lists as monads
doList = do
    a <- [1,2,3]
    return a

doList' =
    [1,2,3] >>= return

h 0 = []
h n = n:(h (n-1))

doList2 = do
    a <- [1,2,3]
    h a

doList2' =
    [1,2,3] >>= h


doList3 = do
    a <- [1,2,3]
    b <- [3,4]
    return (a,b)


doList3' =
    [1,2,3] >>= (
            \a -> [3,4] >>= (
                \b -> return (a * b)
            )
        )