#!/usr/bin/python3
# Annotation.  An annotation creation tool for images.
# Copyright (C) 2012 Joel Granados <joel.granados@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

import unittest
import os.path

class Exif_Handling (unittest.TestCase):
    def setUp(self):
        self.imgdir = "images"

    def test_normGetter1 (self):
        import annexif
        for file in ["exif1.jpg", "exif2.jpg"]:
            pid = annexif.getPlotID(os.path.join(self.imgdir, file))
            self.assertEqual(pid, "1234567890")

    def test_dateGetter1 (self):
        import annexif
        date = annexif.getNormDate(os.path.join(self.imgdir, "exif1.jpg"))
        self.assertEqual(date, "Fri Dec 23 11:46:33 2011")

    def test_normSetter1 (self):
        import annexif
        import shutil
        import os

        tmpfile = os.path.join(self.imgdir,"tmpexif1.jpg")
        shutil.copy( os.path.join(self.imgdir,"exif1.jpg"), tmpfile )

        annexif.setNormDate("New date", tmpfile)
        date = annexif.getNormDate(tmpfile)
        os.remove(tmpfile)

        self.assertEqual(date, "New date")

    def test_plotSetter1 (self):
        import annexif
        import shutil
        import os

        tmpfile = os.path.join(self.imgdir,"tmpexif1.jpg")
        shutil.copy( os.path.join(self.imgdir,"exif1.jpg"), tmpfile )

        annexif.setPlotID("121212", tmpfile)
        pID = annexif.getPlotID(tmpfile)
        os.remove(tmpfile)

        self.assertEqual(pID, "121212")
