module Main where

import Prelude
import Graphics.Canvas (
  CANVAS,
  Context2D,
  CanvasElement,
  beginPath,
  getContext2D,
  setCanvasHeight,
  setCanvasWidth,
  getCanvasElementById,
  closePath,
  lineTo,
  moveTo,
  strokePath
)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import DOM (DOM)
import DOM.Event.EventTarget (eventListener, addEventListener)
import DOM.Event.MouseEvent (clientY, clientX, eventToMouseEvent)
import DOM.Event.Types (EventTarget, EventType(EventType))
import Data.Either (Either(Left, Right))
import Data.Maybe (Maybe(..))
import Data.Foldable (for_)

-- Behind the scenes, CanvasElement is a DOM Element.  So this
-- foreign function will be passed the canvas element.
foreign import showCanvas :: forall e. CanvasElement ->
                              Eff (console :: CONSOLE | e) Unit

-- Behind the scenes, CanvasElement is a native DOM Element, and so is
-- EventTarget. So this foreign function will be passed the canvas element,
-- and we'll return that same element so the type system knows we can
-- bind an event to the canvas.
--
-- This is the bridge between DOM.Event.Types and Graphics.Canvas.
foreign import canvasToEventTarget :: CanvasElement -> EventTarget

-- Draws a square with a width and height at a certain point
drawSquare :: forall e. Context2D -> Number -> Number -> Number -> Number -> Eff (canvas :: CANVAS, console :: CONSOLE | e) Context2D
drawSquare ctx xstart ystart width height = do
  beginPath ctx
  strokePath ctx $ do
    moveTo ctx xstart ystart
    lineTo ctx (xstart + width) ystart
    lineTo ctx (xstart + width) (ystart + height)
    lineTo ctx xstart (ystart + height)
    closePath ctx

main :: forall e. Eff (dom :: DOM, canvas :: CANVAS, console :: CONSOLE | e) Unit
main = do

  -- Set Canvas Width and Height and
  -- and the id of the convas element
  let canvasId = "art"
  let width = 800.0
  let height = 400.0

  -- Attempt to get the canvas
  mcanvas <- getCanvasElementById canvasId

  case mcanvas of
    (Just canvas) -> do
      -- Tell the user things are good
      log "We found the canvas, let's draw!"

      addEventListener (EventType "click") (eventListener (\e -> do
        log "Mouse clicked!"
        case (eventToMouseEvent e) of
          (Right event) ->
            log (show (clientX event) <> "," <> show (clientY event))
          (Left event) ->
            log "Bad Event"

      )) false (canvasToEventTarget canvas)

      -- Set width and height of canvas
      -- and get the context
      setCanvasWidth width canvas
      setCanvasHeight height canvas
      ctx <- getContext2D canvas

      -- Draw a square around the canvas bounds
      drawSquare ctx 0.0 0.0 width height

      -- Draw some squares
      drawSquare ctx 10.0 10.0 10.0 10.0
      drawSquare ctx 30.0 30.0 20.0 20.0

      for_ [7.0,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0] \n -> do
        drawSquare ctx (100.0 + n * 20.0) (50.0) n n

      log ""

    Nothing ->
      log $ "Can't find canvas with id " <> canvasId
