// Define global variables
var ann_can_w = 640;
var ann_can_h = 480;

// The list should be 30% the width of canvas.
var ann_list_w = Math.round(ann_can_w*.3)

// div id containing layout
var ann_layout_id = "ann.layout"

// zoom factor. We use zfactor for zooming in and zfactor+1 for zooming out.
var zfactor = .5;

// The current mouse possition.
var svg = document.createElementNS("http://www.w3.org/2000/svg",'svg');
var pt  = svg.createSVGPoint();

// State var controling the pan
var panOn = false;


repos_layout = function ()
{
    // Center the main layout
    lo = document.getElementById(ann_layout_id);
    lpos = 0;
    if ( window.innerWidth > (ann_can_w + ann_list_w) )
        lpos = (window.innerWidth - (ann_can_w + ann_list_w))/2;
    lo.style.position = "absolute";
    lo.style.left = lpos+"px";
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