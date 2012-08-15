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

// div containing layout
var ann_layout = document.getElementById("ann.layout");
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
}

window.onresize = function ()
{
    // Make sure that layout follows resize
    repos_layout();
}

/* Define global variables */
var ann_can_w = 640;
var ann_can_h = 480;

/* The list should be 30% the width of canvas.*/
var ann_list_w = Math.round(ann_can_w*.3);

ann_ca = new AnnCanvas( 'anncan', document.getElementById("ann.td.canvas"),
    ann_can_w, ann_can_h );
ann_fl = new FileList( 'filelist', document.getElementById("ann.list"),
    ann_list_w, ann_can_h, ann_ca.paper );
