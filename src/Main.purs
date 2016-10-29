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
  clearRect,
  strokePath,
  rect
)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import DOM (DOM)
import DOM.RequestAnimationFrame (requestAnimationFrame)
import DOM.Event.EventTarget (eventListener, addEventListener)
import DOM.Event.MouseEvent (clientY, clientX, eventToMouseEvent)
import DOM.Event.Types (EventTarget, EventType(EventType))
import Data.Either (Either(Left, Right))
import Data.Maybe (Maybe(..))
import Control.Monad.Eff.Timer

import Control.Monad.Except (runExcept)
-- import Control.Monad.Eff.Ref
import Control.Monad.ST

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

type GameConfig =
  { gameWidth :: Number
  , gameHeight :: Number
  }

type GameState =
  { w :: Number
  , h :: Number
  , x :: Number
  , y :: Number }

type Game = --Reader GameConfig GameState
  { config :: GameConfig
  , state :: GameState }

type GameEff a = forall e. Eff
                 ( dom :: DOM
                 , canvas :: CANVAS
                 , console :: CONSOLE | e) a

clearCanvas :: Context2D -> Game -> GameEff Context2D
clearCanvas ctx gs = do
  clearRect ctx { x : 0.0
                , y : 0.0
                , w : gs.config.gameWidth
                , h : gs.config.gameHeight }

drawState :: Context2D -> Game -> GameEff Context2D
drawState ctx gs = do
  clearCanvas ctx gs

  beginPath ctx
  strokePath ctx $ do
    rect ctx { x : gs.state.x
             , y : gs.state.y
             , w : gs.state.w
             , h : gs.state.h }
    closePath ctx

changeBoxSizeBy :: Number -> Game -> Game
changeBoxSizeBy size g =
  { state :
    { w : g.state.w + size
    , h : g.state.h + size
    , x : g.state.x
    , y : g.state.y }
  , config : g.config }

main :: forall e. Eff
           ( st :: ST Game
           , dom :: DOM
           , timer :: TIMER
           , canvas :: CANVAS
           , console :: CONSOLE | e) Unit
main = do

  -- Set Canvas Width and Height and
  -- and the id of the convas element
  let canvasId = "art"

  let game = { config :
                -- Canvas Size
                { gameWidth : 800.0
                , gameHeight : 400.0 }
              , state :
                -- Initial Postion of Box
                { w : 10.0
                , h: 10.0
                , x : 0.0
                , y : 0.0 } }

  gameRef <- newSTRef game

  -- Attempt to get the canvas
  mcanvas <- getCanvasElementById canvasId

  case mcanvas of
    (Just canvas) -> do
      -- Tell the user things are good
      log "We found the canvas, let's draw!"

      addEventListener (EventType "click") (eventListener (\e -> do
        log "Mouse clicked  !"
        case (runExcept $ eventToMouseEvent e) of
          (Right event) ->
            log (show (clientX event) <> "," <> show (clientY event))
          (Left event) ->
            log "Bad Event"

      )) false (canvasToEventTarget canvas)

      ctx <- getContext2D canvas
      setCanvasWidth game.config.gameWidth canvas
      setCanvasHeight game.config.gameHeight canvas

      setInterval 60 $ requestAnimationFrame $ do
        g <- modifySTRef gameRef (changeBoxSizeBy 1.0)
        log $ show g.state.w
        drawState ctx g

      log ""

    Nothing ->
      log $ "Can't find canvas with id " <> canvasId
