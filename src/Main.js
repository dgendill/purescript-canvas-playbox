'use strict';

exports.showCanvas = function(canvas) {
    console.log(canvas);
    return function() {
      return null;
    }
}

exports.canvasToEventTarget = function(canvas) {
  return canvas;
}
