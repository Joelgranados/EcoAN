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

#define ANNEXIF_NAME "Annotation Exif Library"
#define ANNEXIF_VER_MAJOR 0
#define ANNEXIF_VER_MINOR 1

static PyObject*
annexif_getVersion ( PyObject *self, PyObject *args )
{
    PyObject *ver_mes;
    ver_mes = PyString_FromFormat (
            "%s, Version: %d.%d.",
            ANNEXIF_NAME, ANNEXIF_VER_MAJOR, ANNEXIF_VER_MINOR );
    return ver_mes;
}

static PyObject*
annexif_getPlotID ( PyObject *self, PyObject *args )
{

}

static PyObject*
annexif_getNormDate ( PyObject *self, PyObject *args )
{

}

static struct PyMethodDef annexif_methods [] =
{
  { "version", (PyCFunction)annexif_getVersion, METH_NOARGS,
    "Return the version of the library." },

  { "getPlotID", (PyCFunction)annexif_getPlotID, METH_VARARGS,
    "Returns PlotID from image exif data"},

  { "getNormalizationDate",  (PyCFunction)annexif_getNormDate, METH_VARARGS,
    "Returns the date when the normalization was performed" },

  {NULL, NULL, 0, NULL}
};

PyMODINIT_FUNC
init_annexif (void)
{
  (void) Py_InitModule ( "annexif", annexif_methods );
}


