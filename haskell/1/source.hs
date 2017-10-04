myLast :: [a] -> a
myLast [] = error "No last for empty list"
myLast [x] = x
myLast (_:xs) = myLast xs

myButLast :: [a] -> a
myButLast [] = error "No last for empty list"
myButLast [x] = error "No last for the list of length 1"
myButLast [x, y] = x
myButLast (_:xs) = myButLast xs

elementAt :: [a] -> Int -> a
elementAt [] _ = error "Index out of range"
elementAt (x:_) 1 = x
elementAt (_:xs) i = elementAt xs (i - 1)

myLength :: [a] -> Int

myLengthAcc :: [a] -> Int -> Int
myLengthAcc [] acc = acc
myLengthAcc (_:xs) acc = myLengthAcc xs (acc + 1)

myLength xs = myLengthAcc xs 0

myReverse :: [a] -> [a]

myReverseAcc :: [a] -> [a] -> [a]
myReverseAcc [] acc = acc
myReverseAcc (x:xs) acc = myReverseAcc xs (x:acc)

myReverse xs = myReverseAcc xs []

isPalindrome :: (Eq a) => [a] -> Bool

compareLists :: (Eq a) => [a] -> [a] -> Bool
compareLists [] [] = True
compareLists [] ys = False
compareLists xs [] = False
compareLists (x:xs) (y:ys) = x == y && compareLists xs ys

isPalindrome [] = True
isPalindrome xs = compareLists xs (myReverse xs)

data NestedList a = Elem a | List [NestedList a]
flatten :: NestedList a -> [a]
flatten (Elem x) = [x]
flatten (List []) = []
flatten (List ((Elem x):xs)) = x : (flatten (List xs))
flatten (List (x:ys)) = (flatten x) ++ (flatten (List ys))

compress :: (Eq a) => [a] -> [a]

compressAcc :: (Eq a) => [a] -> a -> [a] -> [a]
compressAcc [] _ acc = acc
compressAcc (x:xs) lastX acc
    | lastX == x = compressAcc xs lastX acc
    | otherwise = compressAcc xs x (acc ++ [x])

compress [] = []
compress (x:xs) = compressAcc xs x [x]

pack :: (Eq a) => [a] -> [[a]]

packAcc :: (Eq a) => [a] -> [a] -> [[a]] -> [[a]]
packAcc [] [] acc = acc
packAcc [] similar acc = acc ++ [similar]
packAcc (x:xs) [] acc = packAcc xs [x] acc
packAcc (x:xs) similar acc
    | x == head similar = packAcc xs (x:similar) acc
    | otherwise = packAcc xs [x] (acc ++ [similar])

pack xs = packAcc xs [] []

encode :: (Eq a) => [a] -> [(Int, a)]

encodeAcc :: (Eq a) => [a] -> (Int, a) -> [(Int, a)] -> [(Int, a)]
encodeAcc [] (n, ch) acc = acc ++ [(n, ch)]
encodeAcc (x:xs) (n, ch) acc
    | x == ch = encodeAcc xs (n + 1, ch) acc
    | otherwise = encodeAcc xs (1, x) (acc ++ [(n, ch)])

encode [] = []
encode (x:xs) = encodeAcc xs (1, x) []