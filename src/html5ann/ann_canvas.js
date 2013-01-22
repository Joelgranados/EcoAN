/*
 * Annotation.  An annotation creation tool for images.
 * Copyright (C) 2012 Joel Granados <joel.granados@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

function AnnCanvas ( name, parent, width, height )
{
  this.name = name;
  this.parent = parent;

  this.canvas = document.getElementsByTagName('canvas')[0];
  this.canvas.widht = width;
  this.canvas.height = height;

  this.ctx = this.canvas.getContext('2d');
  trackTransforms(this.ctx);

  this.img = new Image;
  this.img.src = 'undefined.jpg';

  this.currAnns = null;

  /* CSS for the canvas */
  this.canvas.style.border = "1px solid lightgray";
  this.canvas.style.background = "inherit";
  this.canvas.style.fontSize = "inherit";
  this.canvas.style.color = "gray";

  this.ctx.strokeStyle = '#ff0000';
  //FIXME: this needs to change with image size and zoom
  this.ctx.lineWidth = 20;

  this.lastX = this.canvas.width / 2;
  this.lastY = this.canvas.height / 2;
  this.dragStart = null;
  this.dragged = false;
  this.scaleFactor = 1.1;

  this.canvas.onmousedown = ( function (obj) {
    return function (evt) {
      document.body.style.mozUserSelect = document.body.style.webkitUserSelect = document.body.style.userSelect = 'none';
      obj.lastX = evt.offsetX || (evt.pageX - obj.canvas.offsetLeft);
      obj.lastY = evt.offsetY || (evt.pageY - obj.canvas.offsetTop);
      obj.dragStart = obj.ctx.transformedPoint(obj.lastX, obj.lastY);
      obj.dragged = false;
    };
  }) (this);

  this.canvas.onmousemove = ( function(obj) {
    return function (evt) {
      obj.lastX = evt.offsetX || (evt.pageX - obj.canvas.offsetLeft);
      obj.lastY = evt.offsetY || (evt.pageY - obj.canvas.offsetTop);
      obj.dragged = true;
      if (obj.dragStart) {
          var pt = obj.ctx.transformedPoint(obj.lastX, obj.lastY);
          obj.ctx.translate(pt.x - obj.dragStart.x, pt.y - obj.dragStart.y);
          obj.redraw();
      }
    };
  }) (this);

  this.canvas.onmouseup = ( function(obj) {
    return function(evt) {
      obj.dragStart = null;
      if (!obj.dragged)
          obj.zoom(evt.shiftKey ? -1 : 1);
    };
  }) (this);

  var handleScroll = ( function (obj) {
    return function (evt) {
      var delta = evt.wheelDelta ? evt.wheelDelta / 40 : evt.detail ? -evt.detail : 0;
      if (delta)
          obj.zoom(delta);
      return evt.preventDefault() && false;
    };
  }) (this);
  this.canvas.addEventListener('DOMMouseScroll', handleScroll, false);
  this.canvas.addEventListener('mousewheel', handleScroll, false);
}

AnnCanvas.prototype.redraw = function (imgsrc)
{
  if ( imgsrc != undefined )
    this.img.src = imgsrc;

  var p1 = this.ctx.transformedPoint(0, 0);
  var p2 = this.ctx.transformedPoint(this.canvas.width, this.canvas.height);
  this.ctx.clearRect(p1.x, p1.y, p2.x - p1.x, p2.y - p1.y);
  this.ctx.drawImage(this.img, 0, 0);

  if ( this.currAnns == null )
    return;

  for ( var i = 0; i < this.currAnns.anns.length ; i++ )
  {
    var pi = this.currAnns.anns[i].polyInt;
    if ( pi.length < 2 )
      continue;

    this.ctx.beginPath();
    this.ctx.moveTo(pi[pi.length-2], pi[pi.length-1]);
    for ( var j = 0; j < pi.length; j=j+2 )
      this.ctx.lineTo(pi[j], pi[j+1]);
    this.ctx.stroke();
    this.ctx.closePath();
    this.ctx.save();
  }
}

AnnCanvas.prototype.remImg = function() {
  this.currAnns = null;
  this.redraw('undefined.jpg');
}

AnnCanvas.prototype.imgOnSVG = function ( img )
{
  /*FIXME: Probably need to handle the image size. */
  /*FIXME: This is painful. All the methods I tried put the image bytes in the
    resources/Frame/images of the page. When I change of image, the original
    one is not removed. This could potentially use lots of memory. */
  this.img.src = img;
  var p1 = this.ctx.transformedPoint(0, 0);
  var p2 = this.ctx.transformedPoint(this.canvas.width, this.canvas.height);
  this.ctx.clearRect(p1.x, p1.y, p2.x - p1.x, p2.y - p1.y);
  this.ctx.drawImage(this.img, 0, 0);
}

AnnCanvas.prototype.zoom = function (clicks)
{
  var pt = this.ctx.transformedPoint(this.lastX, this.lastY);
  this.ctx.translate(pt.x, pt.y);
  var factor = Math.pow(this.scaleFactor, clicks);
  this.ctx.scale(factor, factor);
  this.ctx.translate(-pt.x, -pt.y);
  this.redraw();
}

AnnCanvas.prototype.csvOnCanvas = function ( anns )
{
  for ( var i = 0; i < anns.anns.length ; i++ )
  {
    var pi = anns.anns[i].polyInt;
    if ( pi.length < 2 )
      continue;

    this.ctx.beginPath();
    this.ctx.moveTo(pi[pi.length-2], pi[pi.length-1]);
    for ( var j = 0; j < pi.length; j=j+2 )
      this.ctx.lineTo(pi[j], pi[j+1]);
    this.ctx.stroke();
    this.ctx.closePath();
    this.ctx.save();
  }
  this.currAnns = anns;
}

/* have JUST the initial message */
AnnCanvas.prototype.remPoly = function ()
{
  /*When we stop using raphael it will be 1*/
  while (this.canvas.childElementCount > 3)
    this.canvas.removeChild(this.canvas.lastChild);
}

/* Handles and tracks the svg transformations */
function trackTransforms(ctx) {
    var svg = document.createElementNS("http://www.w3.org/2000/svg", 'svg');
    var xform = svg.createSVGMatrix();
    /*Returns an SVGMatrix */
    ctx.getTransform = function() {
        return xform;
    };
    var savedTransforms = [];
    var save = ctx.save;
    ctx.save = function() {
        savedTransforms.push(xform.translate(0, 0));
        return save.call(ctx);
    };
    var restore = ctx.restore;
    ctx.restore = function() {
        xform = savedTransforms.pop();
        return restore.call(ctx);
    };
    var scale = ctx.scale;
    ctx.scale = function(sx, sy) {
        xform = xform.scaleNonUniform(sx, sy);
        return scale.call(ctx, sx, sy);
    };
    var rotate = ctx.rotate;
    ctx.rotate = function(radians) {
        xform = xform.rotate(radians * 180 / Math.PI);
        return rotate.call(ctx, radians);
    };
    var translate = ctx.translate;
    ctx.translate = function(dx, dy) {
        xform = xform.translate(dx, dy);
        return translate.call(ctx, dx, dy);
    };
    var transform = ctx.transform;
    ctx.transform = function(a, b, c, d, e, f) {
        var m2 = svg.createSVGMatrix();
        m2.a = a;
        m2.b = b;
        m2.c = c;
        m2.d = d;
        m2.e = e;
        m2.f = f;
        xform = xform.multiply(m2);
        return transform.call(ctx, a, b, c, d, e, f);
    };
    var setTransform = ctx.setTransform;
    ctx.setTransform = function(a, b, c, d, e, f) {
        xform.a = a;
        xform.b = b;
        xform.c = c;
        xform.d = d;
        xform.e = e;
        xform.f = f;
        return setTransform.call(ctx, a, b, c, d, e, f);
    };
    var pt = svg.createSVGPoint();
    /* Returns an SVGPoint */
    ctx.transformedPoint = function(x, y) {
        pt.x = x;
        pt.y = y;
        return pt.matrixTransform(xform.inverse());
    }
}

