module Test.Main where

import Prelude

import Bonjiri as B
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Class.Console as Console
import Effect.Exception (error, throwException)
import Foreign (readString, unsafeToForeign)
import Test.Assert as Assert

foreign import thunkPromise :: Unit -> B.JSPromise Int

fail :: String -> Effect Unit
fail s = do
  Console.error ("Error: " <> s)
  throwException (error s)

main :: Effect Unit
main = do
  -- create a spec from a promise thunk
  let spec1 = B.fromThunk thunkPromise

  B.run
    do \_ -> fail "Spec should not fail"
    do \actual -> Assert.assertEqual { actual, expected: 1 }
    spec1

  -- just map on the value inside
  let spec2 = B.map (add 1) spec1

  B.run
    do \_ -> fail "Spec should not fail"
    do \actual -> Assert.assertEqual { actual, expected: 2 }
    spec2

  -- now throw an error from inside
  let spec3 = B.chain (\_ -> B.reject (unsafeToForeign "error")) spec2

  B.run
    do
      \f ->
        case runExcept (readString f) of
          Right actual -> Assert.assertEqual { actual, expected: "error" }
          Left _ -> fail "Could not decode error correctly"
    do \_ -> fail "Spec should fail"
    spec3

  -- catch the error and resolve a new value
  let spec4 = B.catch (\_ -> B.resolve "hi") spec3

  B.run
    do \_ -> fail "Spec should not fail"
    do \actual -> Assert.assertEqual { actual, expected: "hi" }
    spec4
