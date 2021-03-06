module TokeniserTest where

import Tokeniser
import RobUnit

-- Todo: Use quickcheck

main :: IO ()
main = do
  putStrLn "=========RUNNING TESTS========="
  (putStr . concat . appendFailedCount) tests
  putStrLn "ALL DONE"

tests :: [String]
tests = [
  -- Digits
  makeTest "tokenising digits"
    (tokens JDigits "0001")
    [Digit "0",Digit "0",Digit "0",Digit "1"],
  makeTest "tokenising one digit"
    (tokens JDigits "5")
    [Digit "5"],
  makeTest "tokenising many digits"
    (tokens JDigits "2384283462837462")
    [Digit "2",Digit "3",Digit "8",Digit "4",Digit "2",Digit "8",Digit "3",Digit "4",Digit "6",Digit "2",Digit "8",Digit "3",Digit "7",Digit "4",Digit "6",Digit "2"],
  
  -- Int
  makeTest "tokenising positive int"
    (tokens JInt "1234")
    [Digit "1",Digit "2",Digit "3",Digit "4"],
  makeTest "tokenising negative int"
    (tokens JInt "-937")
    [Minus,Digit "9",Digit "3",Digit "7"],
  
  -- SimpleNumber
  makeTest "tokenising decimal point number"
    (tokens JSimpleNumber "11.454")
    [Digit "1",Digit "1",Dot,Digit "4",Digit "5",Digit "4"],
  makeTest "tokenising integer"
    (tokens JSimpleNumber "43")
    [Digit "4",Digit "3"],
  
  -- Exp
  makeTest "tokenising exponent E+"
    (tokens JExp "E+")
    [Exp EP],
  makeTest "tokenising exponent e-"
    (tokens JExp "e-")
    [Exp LEM],
  makeTest "tokenising exponent e"
    (tokens JExp "e")
    [Exp LE],
  
  --Number
  makeTest "tokenising negative fraction"
    (tokens JNumber "-23.44")
    [Minus,Digit "2",Digit "3",Dot,Digit "4",Digit "4"],
  makeTest "tokenising positive number with standard exponent"
    (tokens JNumber "86.6E23")
    [Digit "8",Digit "6",Dot,Digit "6",Exp E,Digit "2",Digit "3"],
  makeTest "tokenising negative integer with funky exponent"
    (tokens JNumber "-97e-2")
    [Minus, Digit "9",Digit "7",Exp LEM,Digit "2"],
  makeTest "tokenising negative fraction with funky exponenet"
    (tokens JNumber "-5.1E+65")
    [Minus,Digit "5",Dot,Digit "1",Exp EP,Digit "6",Digit "5"],
  
  -- Normal (Value) String
  makeTest "tokenising empty string"
    (tokens JValueString "\"\"")
    [Quote, Quote],
  makeTest "tokenising easy string"
    (tokens JValueString "\"hi\"")
    [Quote, ValueChar "h", ValueChar "i", Quote],
  makeTest "tokenising string with quote inside it"
    (tokens JValueString "\"yo\\\"yo\\\"\"")
    [Quote,ValueChar "y",ValueChar "o",ValueChar "\\\"",ValueChar "y",ValueChar "o",ValueChar "\\\"",Quote],
  makeTest "tokenising string with many quotes inside it"
    (tokens JValueString "\"a\\\"b\\\"cd\"")
    [Quote,ValueChar "a",ValueChar "\\\"",ValueChar "b",ValueChar "\\\"",ValueChar "c",ValueChar "d",Quote],
  makeTest "tokenising string with a hex literal"
    (tokens JValueString "\"HEX:\\ua32f\"")
    [Quote,ValueChar "H",ValueChar "E",ValueChar "X",ValueChar ":",ValueChar "\\ua32f",Quote],
  makeTest "tokenising string with escaped things"
    (tokens JValueString "\"ayy\\b\\rlm\\f\\nao\\t\"")
    [Quote,ValueChar "a",ValueChar "y",ValueChar "y",ValueChar "\\b",ValueChar "\\r",ValueChar "l",ValueChar "m",ValueChar "\\f",ValueChar "\\n",ValueChar "a",ValueChar "o",ValueChar "\\t",Quote],
  
  -- Bool
  makeTest "tokenising true"
    (tokens JBool "true")
    [Const T],
  makeTest "tokenising false"
    (tokens JBool "false")
    [Const F],
  
  -- Null
  makeTest "tokenising null"
    (tokens JNull "null")
    [Const N],
  
  -- Pair
  makeTest "tokenising a pair"
    (tokens JPair "\"memes\":420e+247")
    [Quote,KeyChar "m",KeyChar "e",KeyChar "m",KeyChar "e",KeyChar "s",Quote,Colon,Digit "4",Digit "2",Digit "0",Exp LEP,Digit "2",Digit "4",Digit "7"],
  makeTest "tokenising a pair whose value is a bool"
    (tokens JPair "\"admin\":false")
    [Quote, KeyChar "a", KeyChar "d", KeyChar "m", KeyChar "i", KeyChar "n", Quote, Colon, Const F],
  makeTest "tokenising a pair whose value is an empty array"
    (tokens JPair "\"willsPals\":[]")
    [Quote,KeyChar "w",KeyChar "i",KeyChar "l",KeyChar "l",KeyChar "s",KeyChar "P",KeyChar "a",KeyChar "l",KeyChar "s",Quote,Colon,LSquare,RSquare],
  makeTest "tokenising a pair whose value is a string"
    (tokens JPair "\"ayy\":\"lmao\"")
    [Quote,KeyChar "a",KeyChar "y",KeyChar "y",Quote,Colon,Quote,ValueChar "l",ValueChar "m",ValueChar "a",ValueChar "o",Quote],
  
  -- Object
  makeTest "tokenising an empty object"
    (tokens JObject "{}")
    [LCurly, RCurly],
  makeTest "tokenising an object with one pair"
    (tokens JObject "{\"x\":\"d\"}")
    [LCurly, Quote, KeyChar "x", Quote, Colon, Quote, ValueChar "d", Quote, RCurly],
  makeTest "tokenising an object with a few pairs of different types"
    (tokens JObject "{\"x\":22.5E-7,\"name\":\"buddha\",\"stuff\":[],\"t\":true}")
    [LCurly,Quote,KeyChar "x",Quote,Colon,Digit "2",Digit "2",Dot,Digit "5",Exp EM,Digit "7",Comma,Quote,KeyChar "n",KeyChar "a",KeyChar "m",KeyChar "e",Quote,Colon,Quote,ValueChar "b",ValueChar "u",ValueChar "d",ValueChar "d",ValueChar "h",ValueChar "a",Quote,Comma,Quote,KeyChar "s",KeyChar "t",KeyChar "u",KeyChar "f",KeyChar "f",Quote,Colon,LSquare,RSquare,Comma,Quote,KeyChar "t",Quote,Colon,Const T,RCurly],
  makeTest "tokenising a  big object with lots of whitespace and multiple layers of nesting"
    (tokens JObject "{\"menu\":{\"id\" : \"file\",\n\t\"value\" : \"File\",\n\t\"popup\" : {\"menuitem\" : [1 , 2 ,3, 4]}\n\t}\n}")
    [LCurly,Quote,KeyChar "m",KeyChar "e",KeyChar "n",KeyChar "u",Quote,Colon,LCurly,Quote,KeyChar "i",KeyChar "d",Quote,Colon,Quote,ValueChar "f",ValueChar "i",ValueChar "l",ValueChar "e",Quote,Comma,Quote,KeyChar "v",KeyChar "a",KeyChar "l",KeyChar "u",KeyChar "e",Quote,Colon,Quote,ValueChar "F",ValueChar "i",ValueChar "l",ValueChar "e",Quote,Comma,Quote,KeyChar "p",KeyChar "o",KeyChar "p",KeyChar "u",KeyChar "p",Quote,Colon,LCurly,Quote,KeyChar "m",KeyChar "e",KeyChar "n",KeyChar "u",KeyChar "i",KeyChar "t",KeyChar "e",KeyChar "m",Quote,Colon,LSquare,Digit "1",Comma,Digit "2",Comma,Digit "3",Comma,Digit "4",RSquare,RCurly,RCurly,RCurly],
  
  -- Array
  makeTest "tokenising an empty array"
    (tokens JArray "[]")
    [LSquare, RSquare],
  makeTest "tokenising an array with one thing"
    (tokens JArray "[\"x\"]")
    [LSquare, Quote, ValueChar "x", Quote, RSquare],
  makeTest "tokenising an array with a few things"
    (tokens JArray "[{\"key\":true,\"code\":0099}, null, {}]")
    [LSquare, LCurly, Quote, KeyChar "k", KeyChar "e", KeyChar "y", Quote, Colon, Const T, Comma, Quote, KeyChar "c", KeyChar "o", KeyChar "d", KeyChar "e", Quote, Colon, Digit "0", Digit "0", Digit "9", Digit "9", RCurly, Comma, Const N, Comma, LCurly, RCurly, RSquare]
  
        ]
