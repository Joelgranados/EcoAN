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

function FileList(name, parent, width, height, annCan)
{
  this.name = name;
  this.width = width;
  this.height = height;
  this.list_height = height - 20;
  this.buttons_height = 20;
  this.annCan = annCan;
  this.parent = parent;

  // The selected element in the filelist.
  this.selected = null;

  /* Create file list & buttons html */
  this.list = document.createElement('div');
  this.list.className = this.name + '_list';
  this.list.selected = null;

  this.addBut = document.createElement('span');
  this.addBut.className = this.name + '_butAdd';
  this.input = document.createElement('input');
  this.input.type = 'file';
  this.input.id = this.name + '_input';
  this.input.multiple = true;
  this.addBut.appendChild(this.input);

  this.remBut = document.createElement('span');
  this.remBut.className = this.name + '_butRem';
  this.remBut.innerHTML = 'Rem';

  this.clsBut = document.createElement('span');
  this.clsBut.className = this.name + '_butCls';
  this.clsBut.innerHTML = 'Cls';

  var nav = document.createElement('nav');
  nav.style.textAlign = "center";
  nav.appendChild(this.addBut);
  nav.appendChild(this.remBut);
  nav.appendChild(this.clsBut);

  /* gather everything under a div */
  div = document.createElement('div');
  div.style.whiteSpace = "nowrap";
  div.style.overflow = "hidden";
  div.appendChild(this.list);
  div.appendChild(nav);
  this.parent.appendChild(div);

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

  /* Set all the callbacks */
  this.input.onchange = (function ( obj )
  {
    return function ( evt ) {
      obj.append_files ( evt.target.files );
    };
  })(this);

  this.remBut.onclick = (function ( obj )
  {
    return function() {
      if ( obj.list.selected != null )
      {
        obj.list.removeChild(obj.list.selected);
        obj.annCan.clear(obj.annCan);
      }
    };
  })(this);

  this.clsBut.onclick = (function ( obj )
  {
    return function () {
      var ch = null;
      while ( ch = obj.list.children[0] )
        obj.list.removeChild(ch);
      obj.annCan.clear(obj.annCan);
    };
  })(this);
}

FileList.prototype.ann_filelist_click = function ( obj )
{
  return function ( evt ){
    if ( obj.list.selected != null )
      obj.list.selected.style.background = "";

    obj.list.selected = evt.srcElement;
    obj.list.selected.style.background = "lightgray";

    var reader = new FileReader();
    reader.onload = (function ( theFile ) {
      return function ( e ) {
        obj.annCan.paper.image ( e.target.result, 0, 0,
          ann_can_w, ann_can_h );
      };
    }) ( obj.list.selected.imgObj );

    reader.readAsDataURL ( obj.list.selected.imgObj );
  };
}

FileList.prototype.append_files = function ( files )
{
  endsWith = function ( str, suffix ) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
  }

  /* FIXME: there is probably a faster way of doing this */
  getPairs = function ( files )
  {
    var pairs = [];
    var imgs = [];
    var csvs = [];
    for ( var i = 0, f; f = files[i]; i++ )
      if ( f.type.match('image.*') )
        imgs.push(f);
      else if ( endsWith( f.name, '.csv' ) )
        csvs.push(f);

    /* crappy search */
    for ( var i = 0, f; f = imgs[i]; i++ )
      for ( var j = 0, F; F = csvs[j]; j++ )
        if ( f.name+'.csv' == F.name )
        {
          // we have a winner !!!
          pairs.push([f,F]);
          csvs.splice(j, 1);
          break;
        }

    return pairs;
  }

  var pairs = getPairs(files);
  for ( var i = 0; i < pairs.length ; i++ )
  {
    s = document.createElement('span');
    s.value = escape(pairs[i][0].name);
    s.innerHTML = pairs[i][0].name;
    s.onclick = this.ann_filelist_click(this);
    s.appendChild(document.createElement('br'));
    s.imgObj = pairs[i][0];
    s.csvObj = pairs[i][1];
    this.list.appendChild(s);
  }
}
