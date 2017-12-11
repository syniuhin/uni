module CustomFmap where

fmap' :: (Applicative k) => (a -> b) -> k a -> k b
fmap' f lhs = pure f <*> lhs
