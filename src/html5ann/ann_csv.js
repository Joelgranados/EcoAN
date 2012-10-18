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

//FIXME: We don't do any sanity checks.
function AnnCSVAnnotation ( line )
{
  this.parts = line.split(",");
  this.nonCoorStart = 15;//15 is # of non-coordinates
  this.filename = this.parts[0];
  this.formatVer = this.parts[1];
  this.label = this.parts[2];
  this.reviewer = this.parts[3];
  this.reviewDate = this.parts[4];
  // 5-10 not used
  this.xmin = this.parts[11];
  this.ymin = this.parts[12];
  this.xmax = this.parts[13];
  this.ymax = this.parts[14];

  polyFrom = 0;
  for ( var i = 0; i < this.nonCoorStart; i++ )
    polyFrom = polyFrom + this.parts[i].length +1;
  this.polyString = line.slice(polyFrom);
}

AnnCSVAnnotation.prototype.getPolySize = function ()
{
  return this.parts.length - this.nonCoorStart;
}

AnnCSVAnnotation.prototype.getPolyPoint = function ( offset )
{
  return [ this.parts[ this.nonCoorStart + offset*2],
           this.parts[ this.nonCoorStart + 1 + offset*2]];
}

AnnCSVAnnotation.prototype.getPolyString = function ()
{
  return this.polyString;
}

function AnnCSVReader ( fileString )
{
  this.fileString = fileString;
  this.commentRegex = "[#|%].*";
  this.anns = Array();

  var _anns = fileString.split(/\r?\n/);
  for ( var i = 0, ann; ann = _anns[i]; i++ )
  {
    if ( ann.match(this.commentRegex) != null || ann.length < 1 )
      continue;

    this.anns.push( new AnnCSVAnnotation(ann) );
  }
}

