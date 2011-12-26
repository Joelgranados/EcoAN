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
        self.anndir = os.path.abspath( os.path.join(self.rootdir,".ann") )
        self.imagedir = "images"
        os.mkdir (self.rootdir)

        self.dh = annData.DataHandler ( rootDir=self.rootdir )

    def test_addImage (self):
        images = [os.path.join(self.imagedir,"exif1.jpg"),
                  os.path.join(self.imagedir,"exif2.jpg")]
        self.dh.addImages( images )

        # The images should be in the db 
        for i in range(2):
            imgHash = annData.ImgHandler.calcHash(images[i])
            self.assertNotEqual(self.dh.ah.isFileInDB(imgHash), -1)

        # The plots should be in the db.
        self.assertNotEqual ( self.dh.ah.isPlotInDB("1234567890"), -1 )

        # The images should be in rootDir and anndir
        for i in range(2):
            rootimg = os.path.join ( self.rootdir, os.path.basename(images[i]) )
            annimg = os.path.join ( self.anndir, os.path.basename(images[i]) )
            self.assertTrue ( os.path.exists (rootimg) )
            self.assertTrue ( os.path.exists (rootimg) )

        # The database file should be there.
        dbfile = os.path.join ( self.anndir, "ann.db" )
        self.assertTrue ( os.path.exists(dbfile) )

    def test_reviewer (self):
        self.dh.initDB()
        self.dh.addReviewer("testRev")
        self.assertNotEqual ( self.dh.ah.isRevInDB ("testRev" ), -1 )

        revList = self.dh.ah.getRevList()
        self.assertEqual ( len(revList), 2 )
        self.assertEqual (revList[0][1], "DEFAULT")
        self.assertEqual (revList[1][1], "testRev" )

    def test_label (self):
        self.dh.initDB()
        self.dh.addLabel("testLabel")

        self.assertNotEqual ( self.dh.ah.isLabelInDB ("testLabel"), -1 )

        labList = self.dh.ah.getLabelList()
        self.assertEqual ( len(labList), 2 )
        self.assertEqual ( labList[0][1], "DEFAULT" )
        self.assertEqual ( labList[1][1], "testLabel" )

    def test_annotation (self):
        images = [os.path.join(self.imagedir,"exif1.jpg"),
                  os.path.join(self.imagedir,"exif2.jpg")]

        imgids = self.dh.addImages( images )
        revid = self.dh.addReviewer("testRev")
        labid = self.dh.addLabel("testLabel")

        annid = self.dh.ah.addAnnotation ( "exif1.jpg", False,
                "testLabel", False, "testRev", False,
                "12,12,3,5,5,653,46,345,45,6,32" )
        self.assertEqual ( annid, 1 )

        annid = self.dh.ah.addAnnotation (imgids[0], True,
                labid, True, revid, True, "12,45,6,23,2,43,32,2,231,1" )
        self.assertEqual ( annid, 2 )

    def test_picturesByDate (self):
        images = [os.path.join(self.imagedir,"exif1.jpg"),
                  os.path.join(self.imagedir,"exif2.jpg")]

        imgids = self.dh.addImages( images )
        revid = self.dh.addReviewer("testRev")
        labid = self.dh.addLabel("testLabel")

        self.dh.ah.addAnnotation ( "exif1.jpg", False,
                "testLabel", False, "testRev", False,
                "12,12" )
        self.dh.ah.addAnnotation ( "exif2.jpg", False,
                "testLabel", False, "testRev", False,
                "13,13" )

        rows = self.dh.ah.getPictureListByDate ()

        self.assertEqual ( len(rows), 2 )

    def test_picturesByPlotID (self):
        images = [os.path.join(self.imagedir,"exif1.jpg"),
                  os.path.join(self.imagedir,"exif2.jpg")]

        imgids = self.dh.addImages( images )
        revid = self.dh.addReviewer("testRev")
        labid = self.dh.addLabel("testLabel")

        self.dh.ah.addAnnotation ( "exif1.jpg", False,
                "testLabel", False, "testRev", False,
                "12,12" )
        self.dh.ah.addAnnotation ( "exif2.jpg", False,
                "testLabel", False, "testRev", False,
                "13,13" )

        rows = self.dh.ah.getPictureListByPlotID ()

        self.assertEqual ( len(rows), 2 )

    def tearDown (self):
        pass
        # Remove everything from the Root Dir
        shutil.rmtree(self.rootdir)


