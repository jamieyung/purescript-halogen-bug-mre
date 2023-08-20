### Update: fixed!

Fixed in [this commit](https://github.com/jamieyung/purescript-halogen-bug-mre/commit/41e7095c4dba10cadcd7b96251d1e1acf8cad30d).

Turns out child slots (`HH.slot_ ...`) need to be wrapped in the parent.

Eg. this will be buggy:
```purescript
import Halogen.HTML as HH

render = HH.slot_ ...
```

This will be fine:
```purescript
import Halogen.HTML as HH

render = HH.div_ [ HH.slot_ ... ]
```

### Steps to replicate

1. `npm install`
2. `spago build`
3. `make` (this starts a server, usually on localhost:8000. The exact url will be printed out in the console)
4. Browse to http://127.0.0.1:8000 (or whatever the console printed in step 3
5. Click the button that says `Click me`. This should do the following:
    - Update the url to http://127.0.0.1:8000/#child
    - Update the page (there should be a new button).
6. Click the new button that also says `Click me`. The url should not update, but the page itself should.
7. Now press the back button in your browser. What SHOULD happen is the previous page gets displayed; however, a blank page is shown instead.

### Notes

I did a bit of digging around, and found this spot: https://github.com/purescript-halogen/purescript-halogen/blob/master/src/Halogen/VDom/Driver.purs#L167

```
      Just (RenderState { machine, node, renderChildRef }) -> do
        Ref.write child renderChildRef
        parent <- DOM.parentNode node
        nextSib <- DOM.nextSibling node
        machine' <- EFn.runEffectFn2 V.step machine vdom
        let newNode = V.extract machine'
        when (not unsafeRefEq node newNode) do
          substInParent newNode nextSib parent
        pure $ RenderState { machine: machine', node: newNode, renderChildRef }
```

`parent` seems to be `Just` when clicking the buttons, and is `Nothing` when pressing back in step 7.
I'm not familiar with the Halogen internals, so I don't really know how relevant this is.
