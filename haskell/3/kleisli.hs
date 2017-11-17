module Kleisli where
import Prelude hiding (return)

class Kleisli k where
  (>=>) :: (a -> k b) -> (b -> k c) -> (a -> k c)
  (<=<) :: (b -> k c) -> (a -> k b) -> (a -> k c)
  return :: a -> k a
  (<=<) = flip (>=>)
  (>=>) = flip (<=<)

instance Kleisli Maybe where
  f >=> g = \a ->
    let b = f a
        c = case b of
          Just b0 -> g b0
          Nothing -> Nothing
    in c
  return x = Just x

instance Kleisli [] where
  f >=> g = \a ->
    let b = f a
        c = concat (map g b)
    in c
  return x = [x]

fmap' :: (Kleisli k) => (a -> b) -> k a -> k b
fmap' f lhs = return . f . (flip return) $ lhs
