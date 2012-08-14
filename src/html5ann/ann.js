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

ann_input.onchange = function ( evt )
{
  var files = evt.target.files;

  var output = [];
  for (var i = 0, f; f = files[i]; i++)
  {
    if (!f.type.match('image.*'))
      continue;

    //FIXME: might want to remove all spaces.
    output.push( '<span value="',escape(f.name), '"',
                 ' onclick="ann_filelist_click( this )">',
            escape(f.name), '</span><br>' );
  }

  ann_list.innerHTML = ann_list.innerHTML + output.join('');
}

ann_filelist_click = function ( evt )
{
  if ( ann_file_selected != null )
    ann_file_selected.style.background="";

  ann_file_selected = evt;
  ann_file_selected.style.background = "lightgray";

  console.log("here goes the logic to fetch a file")
}

// d = direction of the zoom. +number -> in, -number -> out
zoom = function ( d )
{
  var ann_can = document.getElementById("ann.canvas");
  var _zfactor=1;
  var zwidth, zheight, zx, zy;

  if (d<0){_zfactor = zfactor+1;} // zoom out
  else if (d>0){_zfactor = zfactor;} // zoom in

  zx = pt.x - ( Math.abs(ann_can.viewBox.baseVal.x - pt.x) * _zfactor );
  zx = (zx < 0)? 0: zx;

  zy = pt.y - ( Math.abs(ann_can.viewBox.baseVal.y - pt.y) * _zfactor );
  zy = (zy < 0)? 0: zy;

  zwidth = (ann_can.viewBox.baseVal.width * _zfactor);
  if ( zwidth+zx > ann_can.width.baseVal.value )
    zwidth = Math.abs ( zx - ann_can.width.baseVal.value );

  zheight = (ann_can.viewBox.baseVal.height * _zfactor);
  if ( zheight+zy > ann_can.height.baseVal.value )
    zheight = Math.abs ( zy - ann_can.height.baseVal.value );

  ann_can.viewBox.baseVal.width = zwidth;
  ann_can.viewBox.baseVal.height = zheight;
  ann_can.viewBox.baseVal.x = zx;
  ann_can.viewBox.baseVal.y = zy;
}

// d_x = Delta for x.
// d_y = Delta for y. Sign matters for both.
pan = function ( d_x, d_y )
{
  var ann_can = document.getElementById("ann.canvas");
  var zx, zy;

  zx = ann_can.viewBox.baseVal.x - d_x;
  zx = (zx < 0)? 0: zx;

  zy = ann_can.viewBox.baseVal.y - d_y;
  zy = (zy < 0)? 0: zy;

  if ( zx+ann_can.viewBox.baseVal.width > ann_can.width.baseVal.value )
    zx = zx - ( ( zx+ann_can.viewBox.baseVal.width )
                - ann_can.width.baseVal.value );

  if ( zy+ann_can.viewBox.baseVal.height > ann_can.height.baseVal.value )
    zy = zy - ( ( zy+ann_can.viewBox.baseVal.height )
                - ann_can.height.baseVal.value );

  ann_can.viewBox.baseVal.x = zx;
  ann_can.viewBox.baseVal.y = zy;
}

main = function () {
  // Creates canvas
  ann_paper = Raphael( document.getElementById("ann.td.canvas"),
                       ann_can_w, ann_can_h );
  ann_paper.canvas.id = "ann.canvas";
  var ann_can = document.getElementById("ann.canvas");

  ann_paper.image( "img.jpg", 0, 0, ann_can_w, ann_can_h );
  r = ann_paper.rect(100, 100, 30, 30).attr({
    'stroke': "#f00",
    'stroke-width': 4});

  ann_paper.setViewBox( 0, 0, ann_can_w, ann_can_h );

  ann_can.onmousemove =  function(e) {
    var prevpt  = svg.createSVGPoint();
    prevpt.x = pt.x;
    prevpt.y = pt.y;

    pt.x = ( ( ann_can.viewBox.baseVal.width/ann_can.width.baseVal.value )
             * e.layerX ) + ann_can.viewBox.baseVal.x;
    pt.y = ( (ann_can.viewBox.baseVal.height/ann_can.height.baseVal.value )
             * e.layerY ) + ann_can.viewBox.baseVal.y;

    if (panOn)
      pan(pt.x-prevpt.x, pt.y-prevpt.y);
  };

  ann_can.onmousedown = function (e) {
    panOn = true;
  }

  ann_can.onmouseup = function (e) {
    panOn = false;
  }

  ann_can.onmousewheel = function(e) {
    zoom(e.wheelDelta);
  };

}

Raphael(main);

