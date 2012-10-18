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
  this.width = width;
  this.height = height;
  this.name = name;
  this.parent = parent;

  /* zoom-out -> zfactor+1, zoom-in -> zfactor*/
  this.zfactor = .5;

  this.paper = Raphael(this.parent, this.width, this.height );
  this.canvas = this.paper.canvas;
  this.canvas.id = "ann.canvas";

  this.img = document.createElementNS('http://www.w3.org/2000/svg','image');
  this.img.setAttributeNS(null,'height', ann_can_h);
  this.img.setAttributeNS(null,'width', ann_can_w);
  this.img.setAttributeNS("http://www.w3.org/1999/xlink",
                          "href", "undefined.jpg" )
  this.canvas.appendChild(this.img);

  this.svg = document.createElementNS("http://www.w3.org/2000/svg",'svg');
  this.pt  = this.svg.createSVGPoint(); // The current mouse possition.
  this.panOn = false; // State var controling the pan

  this.paper.setViewBox( 0, 0, this.width, this.height );

  /* CSS for the canvas */
  this.canvas.style.border = "1px solid lightgray";
  this.canvas.style.background = "inherit";
  this.canvas.style.fontSize = "inherit";
  this.canvas.style.color = "gray";

  /* Create all callbacks */
  this.canvas.onmousemove = ( function ( obj ){
    return function ( e ) {
      var prevpt  = obj.svg.createSVGPoint();
      prevpt.x = obj.pt.x;
      prevpt.y = obj.pt.y;

      obj.pt.x = ( ( obj.canvas.viewBox.baseVal.width
                     / obj.canvas.width.baseVal.value )
                   * e.layerX ) + obj.canvas.viewBox.baseVal.x;
      obj.pt.y = ( ( obj.canvas.viewBox.baseVal.height
                     / obj.canvas.height.baseVal.value )
                   * e.layerY ) + obj.canvas.viewBox.baseVal.y;

      if (obj.panOn)
        obj.pan(obj, obj.pt.x-prevpt.x, obj.pt.y-prevpt.y);
    };
  }) (this);

  this.canvas.onmousedown = ( function ( obj ) {
    return function ( e ) {
      obj.panOn = true;
    };
  }) (this);

  this.canvas.onmouseup = ( function ( obj ) {
    return function ( e ) {
      obj.panOn = false;
    };
  }) (this);

  this.canvas.onmousewheel = ( function ( obj ) {
    return function ( e ) {
      obj.zoom(obj, e.wheelDelta);
    };
  }) (this);
}

// d = direction of the zoom. +number -> in, -number -> out
AnnCanvas.prototype.zoom = function ( obj, d )
{
  var _zfactor=1;
  var zwidth, zheight, zx, zy;

  if (d<0){_zfactor = obj.zfactor+1;} // zoom out
  else if (d>0){_zfactor = obj.zfactor;} // zoom in

  zx = obj.pt.x - ( Math.abs(obj.canvas.viewBox.baseVal.x - obj.pt.x)
                     * _zfactor );
  zx = (zx < 0)? 0: zx;

  zy = obj.pt.y - ( Math.abs(obj.canvas.viewBox.baseVal.y - obj.pt.y)
                     * _zfactor );
  zy = (zy < 0)? 0: zy;

  zwidth = (obj.canvas.viewBox.baseVal.width * _zfactor);
  if ( zwidth+zx > obj.canvas.width.baseVal.value )
    zwidth = Math.abs ( zx - obj.canvas.width.baseVal.value );

  zheight = (obj.canvas.viewBox.baseVal.height * _zfactor);
  if ( zheight+zy > obj.canvas.height.baseVal.value )
    zheight = Math.abs ( zy - obj.canvas.height.baseVal.value );

  obj.canvas.viewBox.baseVal.width = zwidth;
  obj.canvas.viewBox.baseVal.height = zheight;
  obj.canvas.viewBox.baseVal.x = zx;
  obj.canvas.viewBox.baseVal.y = zy;
}

// d_x = Delta for x.
// d_y = Delta for y. Sign matters for both.
AnnCanvas.prototype.pan = function ( obj, d_x, d_y )
{
  var zx, zy;

  zx = obj.canvas.viewBox.baseVal.x - d_x;
  zx = (zx < 0)? 0: zx;

  zy = obj.canvas.viewBox.baseVal.y - d_y;
  zy = (zy < 0)? 0: zy;

  if ( zx+obj.canvas.viewBox.baseVal.width
       > obj.canvas.width.baseVal.value )
    zx = zx - ( ( zx+obj.canvas.viewBox.baseVal.width )
                - obj.canvas.width.baseVal.value );

  if ( zy+obj.canvas.viewBox.baseVal.height
       > obj.canvas.height.baseVal.value )
    zy = zy - ( ( zy+obj.canvas.viewBox.baseVal.height )
                - obj.canvas.height.baseVal.value );

  obj.canvas.viewBox.baseVal.x = zx;
  obj.canvas.viewBox.baseVal.y = zy;
}

AnnCanvas.prototype.csvOnCanvas = function ( anns )
{
  for ( var i = 0; i < anns.anns.length ; i++ )
  {
    var polygon = document.createElementNS('http://www.w3.org/2000/svg','polygon');
    polygon.setAttribute("points", anns.anns[i].polyString);
    this.canvas.appendChild(polygon);
  }
}

AnnCanvas.prototype.imgOnSVG = function ( img )
{
  /*FIXME: Probably need to handle the image size. */
  /*FIXME: This is painful. All the methods I tried put the image bytes in the
    resources/Frame/images of the page. When I change of image, the original
    one is not removed. This could potentially use lots of memory. */
  this.img.setAttributeNS("http://www.w3.org/1999/xlink", "href", img )
}

/* have JUST the initial message */
AnnCanvas.prototype.clnSVG = function ()
{
  /*When we stop using raphael it will be 1*/
  while (this.canvas.childElementCount > 3)
    this.canvas.removeChild(this.canvas.lastChild);
}
