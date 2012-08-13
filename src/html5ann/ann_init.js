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

// Define global variables
var ann_can_w = 640;
var ann_can_h = 480;

// The list should be 30% the width of canvas.
var ann_list_w = Math.round(ann_can_w*.3);
// 20 pixels of the buttons.
var ann_list_h = ann_can_h - 20;

// List buttons
var ann_list_add = document.getElementById("ann.list.buttons.add");
var ann_list_del = document.getElementById("ann.list.buttons.del");
var ann_list_cls = document.getElementById("ann.list.buttons.cls");

// The file list
var ann_list = document.getElementById("ann.filelist");
var ann_input = document.getElementById("ann.input");

// div containing layout
var ann_layout = document.getElementById("ann.layout");

// zoom-in -> zfactor
// zoom-out -> zfactor+1
var zfactor = .5;

// The current mouse possition.
var svg = document.createElementNS("http://www.w3.org/2000/svg",'svg');
var pt  = svg.createSVGPoint();

// The selected element in the filelist.
var ann_file_selected = null;

// State var controling the pan
var panOn = false;

repos_layout = function ()
{
    // Center the main layout
    lpos = 0;
    if ( window.innerWidth > (ann_can_w + ann_list_w) )
        lpos = (window.innerWidth - (ann_can_w + ann_list_w))/2;
    ann_layout.style.position = "absolute";
    ann_layout.style.left = lpos+"px";
}

window.onload = function ()
{
  // Center the main layout
  repos_layout();

  // Size the file list
  ann_list.style.width = ann_list_w+"px";
  ann_list.style.height = ann_list_h+"px";
  ann_list.style.overflow = "scroll";
}

window.onresize = function ()
{
    // Make sure that layout follows resize
    repos_layout();
}
