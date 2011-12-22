/*
 * Annotation.  An annotation creation tool for images.
 * Copyright (C) 2011 Joel Granados <joel.granados@gmail.com>
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

#include <Python.h>
#include <exiv2/exiv2.hpp>

#define ANNEXIF_NAME "Annotation Exif Library"
#define ANNEXIF_VER_MAJOR 0
#define ANNEXIF_VER_MINOR 1

using namespace std;

#define ANNEXIF_RETERR( message ) \
  { \
    PyErr_SetString ( PyExc_Exception, message ); \
    return NULL; \
  }

static PyObject*
annexif_getVersion ( PyObject *self, PyObject *args )
{
    PyObject *ver_mes;
    ver_mes = PyBytes_FromFormat (
            "%s, Version: %d.%d.",
            ANNEXIF_NAME, ANNEXIF_VER_MAJOR, ANNEXIF_VER_MINOR );
    return ver_mes;
}

static string
annexif_getElem ( const char* img_file,
                  const bool isPlotID,
                  const bool isNormDate )
{
  string sample;
  int size, from, to;

  if ( isPlotID == isNormDate)
    return "";
  else if ( isPlotID )
  {
    sample = "plotid=";
    size = 6;
  }
  else if ( isNormDate )
  {
    sample = "normalized=";
    size = 11;
  }

  vector<string> elements;
  Exiv2::Image::AutoPtr img = Exiv2::ImageFactory::open ( img_file );
  Exiv2::ExifData &exifData = img->exifData();
  Exiv2::ExifData::iterator edi =
    exifData.findKey ( Exiv2::ExifKey ( "Exif.Photo.UserComment" ) );
  string comment = (*edi).toString();

  /* It needs to have something */
  if ( comment.length() <= 0 )
    throw;

  from = comment.find ( sample );
  if ( from == string::npos )
    throw;

  from = from + size;

  to = comment.find ( ",\n\r", from );
  if ( to == string::npos || from+1 == to )
    throw;

  return comment.substr(from, to).data();
}

static PyObject*
annexif_getPlotID ( PyObject *self, PyObject *args )
{
  char *img_file;
  PyObject *pyPlot_id;
  long plot_id = -1;

  if ( !PyArg_ParseTuple ( args, "s", &img_file ) )
    ANNEXIF_RETERR ( "Invalid parameters for getPlotID." );

  try {
    string plotidstr = annexif_getElem ( img_file, 1, 0 );

    plot_id = (long) atol ( plotidstr.data() );

    if ( plot_id == -1 )
      ANNEXIF_RETERR( "Plot ID not found in exif data." )

  } catch ( Exiv2::AnyError& ae ) {
      ANNEXIF_RETERR( "Unable to access image file to read EXIF data" );
  }

  pyPlot_id = Py_BuildValue ( "l", plot_id );
  if ( pyPlot_id == NULL )
    ANNEXIF_RETERR ( "Plot ID not found in exif data." );

  return pyPlot_id;
}

static PyObject*
annexif_getNormDate ( PyObject *self, PyObject *args )
{
  char *img_file;
  string datestr;
  PyObject *pyDatestr;

  if ( !PyArg_ParseTuple ( args, "s", &img_file ) )
    ANNEXIF_RETERR ( "Invalid parameters for getPlotID." );

  try {
    datestr = annexif_getElem ( img_file, 1, 0 );

    if ( datestr.compare("") == 0 )
      ANNEXIF_RETERR( "Plot ID not found in exif data." )

  } catch ( Exiv2::AnyError& ae ) {
      ANNEXIF_RETERR( "Unable to access image file to read EXIF data" );
  }

  pyDatestr = Py_BuildValue ( "s", datestr.data() );
  if ( pyDatestr == NULL )
    ANNEXIF_RETERR ( "Plot ID not found in exif data." );

  return pyDatestr;
}

static bool
annexif_writeexif ( string &norm_date,
                    string &plot_id ,
                    const char *img_file )
{
  std::stringstream userComment;
  userComment << "charset=Ascii normalized="
              << norm_date
              << ",plotid="
              << plot_id;

  Exiv2::Image::AutoPtr img = Exiv2::ImageFactory::open(img_file);
  img->readMetadata ();
  Exiv2::ExifData &srcExifData = img->exifData();
  srcExifData ["Exif.Photo.UserComment"] = userComment.str();
  img->setExifData ( srcExifData );
  img->writeMetadata ();
  return true;
}

static PyObject*
annexif_setPlotID ( PyObject *self, PyObject *args )
{
  char *py_plot_id, *img_file;

  if ( !PyArg_ParseTuple ( args, "ss", &py_plot_id, &img_file ) )
    ANNEXIF_RETERR ( "Invalid parameters for setPlotID." );

  string norm_date = annexif_getElem ( img_file, false, true );
  string plot_id(py_plot_id);

  if ( annexif_writeexif ( norm_date, plot_id, img_file ) )
    Py_RETURN_TRUE;
  else
    Py_RETURN_FALSE;
}

static PyObject*
annexif_setNormDate ( PyObject *self, PyObject *args )
{
  char *py_norm_date, *img_file;

  if ( !PyArg_ParseTuple ( args, "ss", &py_norm_date, &img_file ) )
    ANNEXIF_RETERR ( "Invalid parameters for getNormDate." );

  string plot_id = annexif_getElem ( img_file, true, false );
  string norm_date(py_norm_date);

  if ( annexif_writeexif ( norm_date, plot_id, img_file ) )
    Py_RETURN_TRUE;
  else
    Py_RETURN_FALSE;

}

static struct PyMethodDef annexif_methods [] =
{
  { "version", (PyCFunction)annexif_getVersion, METH_NOARGS,
    "Return the version of the library." },

  { "getPlotID", (PyCFunction)annexif_getPlotID, METH_VARARGS,
    "Returns PlotID from image exif data"},

  { "getNormalizationDate",  (PyCFunction)annexif_getNormDate, METH_VARARGS,
    "Returns the date when the normalization was performed" },

  { "setPlotID", (PyCFunction)annexif_setPlotID, METH_VARARGS,
    "Sets the plot id in the exif data" },

  { "setNormDate", (PyCFunction)annexif_setNormDate, METH_VARARGS,
    "Sets the normalization date in the exif data" },

  {NULL, NULL, 0, NULL}
};

static struct PyModuleDef annexif = {
  PyModuleDef_HEAD_INIT,
  "annexif",
  NULL, /* Documentation */
  -1, /* Keep track in global variables */
  annexif_methods
};

PyMODINIT_FUNC
PyInit_annexif (void)
{
  (void) PyModule_Create ( &annexif );
}
