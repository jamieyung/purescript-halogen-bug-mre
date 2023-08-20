module Main where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (class MonadEffect, liftEffect)
import Halogen as H
import Halogen.Aff as HA
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.VDom.Driver (runUI)
import Routing.Hash (matchesWith, setHash)
import Type.Proxy (Proxy(..))

main :: Effect Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  halogenIO <- runUI component unit body

  -- listen to hash changes, parse the hash, and trigger handleQuery
  liftEffect $ void $ matchesWith (Right <<< parseRoute) \old new ->
    when (old /= Just new) $ launchAff_ $ void $ halogenIO.query $ H.mkTell $ Navigate new

data Route = Home | Child

derive instance Eq Route
instance Show Route where
  show Home = "Home"
  show Child = "Child"

parseRoute :: String -> Route
parseRoute "" = Home
parseRoute _ = Child

data Query a = Navigate Route a

component :: forall i o m. MonadEffect m => H.Component Query i o m
component = H.mkComponent
  { initialState: const Home
  , render: case _ of
      Home -> HH.button [ HE.onClick \_ -> unit ] [ HH.text "Click me" ]
      Child -> HH.div_ [ HH.slot_ (Proxy :: Proxy "child") unit child unit ]
  , eval: H.mkEval $ H.defaultEval
      { handleAction = \_ ->
          -- This updates the hash, which triggers the hash change listener above.
          -- Because the hash is set to something other than empty string, the
          -- new route will be `Child`.
          liftEffect $ setHash "child"
      , handleQuery = case _ of
          Navigate dest a -> do
            H.put dest
            pure (Just a)
      }
  }

child :: forall q i o m. H.Component q i o m
child = H.mkComponent
  { initialState: const true
  , render: case _ of
      true -> HH.div_
        [ HH.text "If you press back in your browser now, the prev view will be rendered fine"
        , HH.br_
        , HH.button [ HE.onClick \_ -> unit ] [ HH.text "Click me" ]
        ]
      false -> HH.text "If you press back in the browser now, you'll get a blank screen (No longer true; wrapping the child slot in a div fixes the issue)"
  , eval: H.mkEval $ H.defaultEval { handleAction = \_ -> H.put false }
  }
