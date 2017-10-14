myLast :: [a] -> a
myLast [] = error "No last for empty list"
-- Tail recursion final case
myLast [x] = x
-- Tail recursion 'iteration'
myLast (_:xs) = myLast xs

myButLast :: [a] -> a
myButLast [] = error "No last for empty list"
myButLast [x] = error "No last for the list of length 1"
-- Tail recursion final case
myButLast [x, y] = x
-- Tail recursion 'iteration'
myButLast (_:xs) = myButLast xs

elementAt :: [a] -> Int -> a
-- Will be caught on empty list and any index
elementAt [] _ = error "Index out of range"
-- Tail rec final case
elementAt (x:_) 1 = x
-- Find the elementAt i-1 of list's tail
elementAt (_:xs) i = elementAt xs (i - 1)

myLength :: [a] -> Int
-- Accumulator function to count number of elements
myLengthAcc :: [a] -> Int -> Int
myLengthAcc [] acc = acc
myLengthAcc (_:xs) acc = myLengthAcc xs (acc + 1)

myLength xs = myLengthAcc xs 0

myReverse :: [a] -> [a]
-- Accumulator function used to recursively reverse a list
myReverseAcc :: [a] -> [a] -> [a]
myReverseAcc [] acc = acc
-- Prepend current list head to accumulator list
myReverseAcc (x:xs) acc = myReverseAcc xs (x:acc)

myReverse xs = myReverseAcc xs []

isPalindrome :: (Eq a) => [a] -> Bool
-- Auxiliary function used to compare 2 lists
compareLists :: (Eq a) => [a] -> [a] -> Bool
compareLists [] [] = True
-- Empty =/= non-empty
compareLists [] ys = False
-- Non-empty =/= empty
compareLists xs [] = False
-- Compare heads and tails
compareLists (x:xs) (y:ys) = x == y && compareLists xs ys

isPalindrome [] = True
-- Compare list with it's reversed version
isPalindrome xs = compareLists xs (myReverse xs)

data NestedList a = Elem a | List [NestedList a]
flatten :: NestedList a -> [a]
flatten (Elem x) = [x]
flatten (List []) = []
-- xs may be either Elem or List, but in this case it has a type
-- of [NestedList a] and we make a List of it in order to pass it
-- to flatten
flatten (List ((Elem x):xs)) = x : (flatten (List xs))
-- Here x is List, has type NestedList a, same logic for ys as above
flatten (List (x:ys)) = (flatten x) ++ (flatten (List ys))

compress :: (Eq a) => [a] -> [a]
-- Accumulator function to keep track of current value in recursion
compressAcc :: (Eq a) => [a] -> a -> [a] -> [a]
compressAcc [] _ acc = acc
compressAcc (x:xs) lastX acc
    | lastX == x = compressAcc xs lastX acc -- Go ahead, nothing changed
    | otherwise = compressAcc xs x (acc ++ [x]) -- Append distinct character and remember new one

compress [] = []
compress (x:xs) = compressAcc xs x [x]

pack :: (Eq a) => [a] -> [[a]]
-- Yet another accumulator function
packAcc :: (Eq a) => [a] -> [a] -> [[a]] -> [[a]]
-- Edge case if inital list is empty
packAcc [] [] acc = acc
-- Final case of tail rec
packAcc [] similar acc = acc ++ [similar]
-- First 'iteration' of accumulator function
packAcc (x:xs) [] acc = packAcc xs [x] acc
-- Usual 'iteration' of accumulator function
packAcc (x:xs) similar acc
    | x == head similar = packAcc xs (x:similar) acc -- Keep going on the same character
    | otherwise = packAcc xs [x] (acc ++ [similar]) -- Change character

pack xs = packAcc xs [] []

encode :: (Eq a) => [a] -> [(Int, a)]
-- Same logic as 2 functions above
encodeAcc :: (Eq a) => [a] -> (Int, a) -> [(Int, a)] -> [(Int, a)]
encodeAcc [] (n, ch) acc = acc ++ [(n, ch)]
encodeAcc (x:xs) (n, ch) acc
    | x == ch = encodeAcc xs (n + 1, ch) acc
    | otherwise = encodeAcc xs (1, x) (acc ++ [(n, ch)])

encode [] = []
encode (x:xs) = encodeAcc xs (1, x) []
