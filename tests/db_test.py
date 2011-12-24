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
import annData
import os
import os.path
import shutil

class DB_Creation (unittest.TestCase):
    def setUp (self):
        # Create the Root Dir
        self.rootdir = os.path.abspath("TMPROOTDIRECTORY")
        self.imagedir = "images"
        os.mkdir (self.rootdir)

        self.dh = annData.DataHandler ( rootDir=self.rootdir )

    def test_addImage (self):
        images = [os.path.join(self.imagedir,"exif1.jpg"),
                  os.path.join(self.imagedir,"exif2.jpg")]
        self.dh.addImages( images )
        self.assertNotEqual ( self.dh.ah.isPlotInDB("1234567890"), -1 )

        for i in range(2):
            imgHash = annData.ImgHandler.calcHash(images[i])
            self.assertNotEqual(self.dh.ah.isFileInDB(imgHash), -1)

    def tearDown (self):
        pass
        # Remove everything from the Root Dir
        shutil.rmtree(self.rootdir)


