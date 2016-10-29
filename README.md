# PureScript Canvas Playbox

Just playing around with PureScript's [Graphics.Canvas](https://pursuit.purescript.org/packages/purescript-canvas/1.0.0/docs/Graphics.Canvas#t:CanvasElement) and [Dom.Event.Types](https://pursuit.purescript.org/packages/purescript-dom/2.2.1/docs/DOM.Event.Types#t:Event)
modules.  The most important part of this example is the canvasToEventTarget
foreign function.

```purescript
-- Behind the scenes, CanvasElement is a native DOM Element, and so is
-- EventTarget. So this foreign function will be passed the canvas element,
-- and we'll return that same element so the type system knows we can
-- bind an event to the canvas.
--
-- This is the bridge between DOM.Event.Types and Graphics.Canvas.
foreign import canvasToEventTarget :: CanvasElement -> EventTarget
```

So then you can use use [addEventListener](https://pursuit.purescript.org/packages/purescript-dom/2.2.1/docs/DOM.Event.EventTarget#v:addEventListener) from DOM.Event.EventTarget to bind an event listener to the Canvas element and
get [MouseEvent data](https://pursuit.purescript.org/packages/purescript-dom/2.2.1/docs/DOM.Event.MouseEvent#v:eventToMouseEvent).



# Install

Have bower, npm, and PureScript installed globally.  Clone the repo into a folder
and then run this in the folder...

```
bower install
npm run server
```

Then point your browser to http://localhost:1337/dist/

# History

* Tag 1.0.0 - Able to draw shapes on the canvas and listen for clicks

![Preview](/img/preview.jpg)

* Tag 1.1.0 - Animating rectangle size with setInterval and requestAnimationFrame
