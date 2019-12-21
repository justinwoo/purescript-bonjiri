module Bonjiri where

import Prelude hiding (map, pure, apply)

import Effect (Effect)
import Foreign (Foreign)
import Prim.TypeError (class Fail, Text)

foreign import data JSPromise :: Type -> Type

newtype PromiseSpec a = PromiseSpec (Effect (JSPromise a))

fromEffect :: forall a. NotJSPromise a => Effect (JSPromise a) -> PromiseSpec a
fromEffect = PromiseSpec

foreign import mkPromiseSpec :: forall a
   . NotJSPromise a
  -- callback of resolve, reject
  => ((a -> Effect Unit) -> (Foreign -> Effect Unit) -> Effect Unit)
  -> PromiseSpec a

pure :: forall a. NotJSPromise a => a -> PromiseSpec a
pure = fromEffect <<< resolve

-- | takes onError, onSuccess, and a PromiseSpec to run a JSPromise
-- | onError uses Foreign, since any value can be returned from throw
foreign import run :: forall a
   . NotJSPromise a
  => (Foreign -> Effect Unit)
  -> (a -> Effect Unit)
  -> PromiseSpec a
  -> Effect Unit

-- | create a JSPromise of a pure value in a thunk
foreign import resolve :: forall a
   . NotJSPromise a
  => a
  -> Effect (JSPromise a)

-- | throw a JSPromise of a pure value in a thunk
foreign import reject :: Foreign -> Effect (JSPromise Void)

-- | map the value in a promise spec
map :: forall a b. NotJSPromise b => (a -> b) -> PromiseSpec a -> PromiseSpec b
map fn spec = chain (resolve <<< fn) spec

-- | Chain a promise spec
foreign import chain :: forall a b
   . NotJSPromise b
  => (a -> Effect (JSPromise b))
  -> PromiseSpec a
  -> PromiseSpec b

-- | Chain an error from a promise spec
foreign import catch :: forall a b
   . NotJSPromise b
  => (a -> Effect (JSPromise b))
  -> PromiseSpec a
  -> PromiseSpec b

-- | Process all promise specs in an array
foreign import all :: forall a
   . NotJSPromise a
  => Array (PromiseSpec a)
  -> PromiseSpec (Array a)

-- | apply a function to a value inside promise specs
foreign import apply :: forall a b
   . NotJSPromise a
  => NotJSPromise b
  => PromiseSpec (a -> b)
  -> PromiseSpec a
  -> PromiseSpec b

-- | Make sure we don't have JS promises nested
class NotJSPromise a
instance notJSPromiseFail ::
  ( Fail (Text "JSPromises cannot be nested due to JS flattening behaviors")
  ) => NotJSPromise (JSPromise a)
else instance notJSPromiseGood :: NotJSPromise a

-- | Probably unlawful instances
instance functorPromiseSpec :: Functor PromiseSpec where
  map = map

instance applyPromiseSpec :: Apply PromiseSpec where
  apply = apply

instance applicativePromiseSpec :: Applicative PromiseSpec where
  pure = pure
