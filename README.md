# PureScript-Bonjiri

An implementation for working with JS Promises via specifications. For when you want to make use of existing mechanisms in JS libs and debugging tools.

![](./bonjiri.jpg)

Bonjiri is basically chicken butt.

## Usage

see Tests.

``` purs
foreign import thunkPromise :: Unit -> B.JSPromise Int

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
```

## FAQ

### Why are there no instances?

Please help convince me there are valid instances that can be written here. It does not seem to be the case that you can.
