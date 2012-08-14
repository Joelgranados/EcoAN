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

function FileList(name, parent, width, height, paper)
{
  this.name = name;
  this.id = name;
  this.class = name;
  this.width = width;
  this.height = height;
  this.list_height = height - 20;
  this.buttons_height = 20;
  this.paper = paper;
  this.parent = parent;

  // The selected element in the filelist.
  this.selected = null;

  /* Create file list & buttons html */
  this.list = document.createElement('div');
  this.list.className = this.class + '_list';
  this.list.selected = null;

  this.addBut = document.createElement('span');
  this.addBut.className = this.id + '_butAdd';
  this.input = document.createElement('input');
  this.input.type = 'file';
  this.input.id = this.id + '_input';
  this.input.multiple = true;
  this.addBut.appendChild(this.input);

  this.remBut = document.createElement('span');
  this.remBut.className = this.id + '_butRem';
  this.remBut.innerHTML = 'Rem';

  this.clsBut = document.createElement('span');
  this.clsBut.className = this.id + '_butCls';
  this.clsBut.innerHTML = 'Cls';

  var nav = document.createElement('nav');
  nav.style.textAlign = "center";
  nav.appendChild(this.addBut);
  nav.appendChild(this.remBut);
  nav.appendChild(this.clsBut);

  this.parent.appendChild(this.list);
  this.parent.appendChild(nav);

  /* Create file list & buttons CSS. */
  // FIXME: It might be a messy for multiple filelist obj.
  var style = document.createElement('style');
  style.type = 'text/css';
  style.innerHTML = '.' + this.list.className + ' {'
    + 'border:1px solid lightgray;'
    + 'background:inherit;'
    + 'font-size:inherit;'
    + 'overflow-x:scroll;'
    + 'overflow-y:scroll;'
    + 'overflow:scroll;'
    + 'color: gray;'
    + 'width: ' + this.width + 'px;'
    + 'height: ' + this.list_height + 'px;'
    + '}'

    + '.'+this.addBut.className+','
    + '.'+this.remBut.className+','
    + '.'+this.clsBut.className+'{'
    + 'opacity:.2;'
    + 'font-size: inherit;'
    + 'color: gray;'
    + 'padding: 0px 10px;'
    + 'background: inherit;'
    + '-moz-border-radius: 7px;'
    + '-webkit-border-radius: 7px;'
    + 'border-radius: 7px;'
    + 'border: 1px solid gray;'
    + '}'

    + '.'+this.addBut.className+':hover,'
    + '.'+this.remBut.className+':hover,'
    + '.'+this.clsBut.className+':hover{'
    + 'opacity:1;'
    + '-o-transition: opacity 1s;'
    + '-moz-transition: opacity 1s;'
    + '-webkit-transition: opacity 1s;'
    + 'transition: opacity 1s;'
    + '}'

    + '.'+this.addBut.className+' input{'
    + 'font-size: 8px;'
    + 'width: 60px;'
    + '}';

  document.getElementsByTagName('head')[0].appendChild(style);
}

FileList.prototype.ann_filelist_click = function ( evt )
{
  tmpList = evt.srcElement.parentElement;
  if ( tmpList.selected != null )
    tmpList.selected.style.background="";

  tmpList.selected = evt.srcElement;
  tmpList.selected.style.background = "lightgray";

  console.log("here goes the logic to fetch a file")
}

FileList.prototype.append_files = function ( files )
{
  for (var i = 0, f; f = files[i]; i++)
  {
    if (!f.type.match('image.*'))
      continue;

    s = document.createElement('span');
    s.value = escape(f.name);
    //FIXME: might want to remove all spaces.
    s.innerHTML = escape(f.name);
    s.onclick = this.ann_filelist_click;
    this.list.appendChild(s);
    this.list.appendChild(document.createElement('br'));
  }
}
