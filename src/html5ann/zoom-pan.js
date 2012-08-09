Raphael(function() {
    // Creates canvas
    var paper = Raphael( document.getElementById("ann.content.canvas"),
                         ann_can_w, ann_can_h );
    paper.canvas.id = "canAnn";
    var canAnn = document.getElementById("canAnn");

    paper.image( "img.jpg", 0, 0, ann_can_w, ann_can_h );
    r = paper.rect(100, 100, 30, 30).attr({
        'stroke': "#f00",
        'stroke-width': 4});

    paper.setViewBox( 0, 0, ann_can_w, ann_can_h );

    canAnn.onmousemove =  function(e) {
        var prevpt  = svg.createSVGPoint();
        prevpt.x = pt.x;
        prevpt.y = pt.y;

        pt.x = ( ( canAnn.viewBox.baseVal.width / canAnn.width.baseVal.value )
                 * e.layerX ) + canAnn.viewBox.baseVal.x;
        pt.y = ( (canAnn.viewBox.baseVal.height / canAnn.height.baseVal.value )
                 * e.layerY ) + canAnn.viewBox.baseVal.y;

        if (panOn)
            pan(pt.x-prevpt.x, pt.y-prevpt.y);
    };

    canAnn.onmousedown = function (e) {
        panOn = true;
    }

    canAnn.onmouseup = function (e) {
        panOn = false;
    }

    canAnn.onmousewheel = function(e) {
        zoom(e.wheelDelta);
    };

    // d = direction of the zoom. +number -> in, -number -> out
    zoom = function ( d )
    {
        var _zfactor=1;
        var zwidth, zheight, zx, zy;

        if (d<0){_zfactor = zfactor+1;} // zoom out
        else if (d>0){_zfactor = zfactor;} // zoom in

        zx = pt.x - ( Math.abs(canAnn.viewBox.baseVal.x - pt.x) * _zfactor );
        zx = (zx < 0)? 0: zx;

        zy = pt.y - ( Math.abs(canAnn.viewBox.baseVal.y - pt.y) * _zfactor );
        zy = (zy < 0)? 0: zy;

        zwidth = (canAnn.viewBox.baseVal.width * _zfactor);
        if ( zwidth+zx > canAnn.width.baseVal.value )
            zwidth = Math.abs ( zx - canAnn.width.baseVal.value );

        zheight = (canAnn.viewBox.baseVal.height * _zfactor);
        if ( zheight+zy > canAnn.height.baseVal.value )
            zheight = Math.abs ( zy - canAnn.height.baseVal.value );

        paper.setViewBox( zx, zy, zwidth, zheight );
    }

    // d_x = Delta for x.
    // d_y = Delta for y. Sign matters for both.
    pan = function ( d_x, d_y )
    {
        var zx, zy;

        zx = canAnn.viewBox.baseVal.x - d_x;
        zx = (zx < 0)? 0: zx;

        zy = canAnn.viewBox.baseVal.y - d_y;
        zy = (zy < 0)? 0: zy;

        if ( zx+canAnn.viewBox.baseVal.width > canAnn.width.baseVal.value )
            zx = zx - ( ( zx+canAnn.viewBox.baseVal.width )
                        - canAnn.width.baseVal.value );

        if ( zy+canAnn.viewBox.baseVal.height > canAnn.height.baseVal.value )
            zy = zy - ( ( zy+canAnn.viewBox.baseVal.height )
                        - canAnn.height.baseVal.value );

        paper.setViewBox( zx, zy,
                          canAnn.viewBox.baseVal.width,
                          canAnn.viewBox.baseVal.height );
    }

});
