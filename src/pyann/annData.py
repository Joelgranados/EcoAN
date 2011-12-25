#!/usr/bin/python3
# Annotation.  An annotation creation tool for images.
# Copyright (C) 2010 Joel Granados <joel.granados@gmail.com>
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

import sqlite3
import os
import os.path
import hashlib
import mimetypes
import shutil
import annexif

#{{{ Annhandler
class AnnHandler:

    def __init__ ( self, rootDir = '.' ):
        if not os.path.exists(rootDir):
            raise Exception("Root dir does not exist")

        self.rootDir = rootDir
        self.annDir = os.path.join (self.rootDir, ".ann")
        self.dbFile = os.path.join ( self.annDir, "ann.db" )

    def dbExists ( self ):
        return os.path.isfile ( self.dbFile )

    def initDB ( self ):
        conn = sqlite3.connect(self.dbFile)
        c = conn.cursor()
        c.executescript ( """
            create table ANNpicture (
                pid INTEGER PRIMARY KEY,
                phash TEXT NOT NULL UNIQUE,
                pfile TEXT NOT NULL,
                trackplot INTEGER NOT NULL,
                pdate DATE NOT NULL,
                FOREIGN KEY (trackplot) REFERENCES ANNplot(plid) ) ;

            create table ANNlabel (
                lid INTEGER PRIMARY KEY,
                labelname TEXT NOT NULL UNIQUE );

            create table ANNreviewer (
                rid INTEGER PRIMARY KEY,
                reviewername TEXT UNIQUE NOT NULL );

            create table ANNplot (
                plid INTEGER PRIMARY KEY,
                plotID INTEGER NOT NULL UNIQUE,
                plotdesc TEXT );

            create table ANNmetadata (
                mid INTEGER PRIMARY KEY,
                mname TEXT UNIQUE,
                mvalue TEXT );

            PRAGMA foreign_keys = ON;
            create table ANNannotation (
                akey INTEGER PRIMARY KEY,
                trackpicture INTEGER NOT NULL,
                tracklabel INTEGER NOT NULL,
                trackreviewer INTEGER NOT NULL,
                anndate DATE NOT NULL,
                polygon TEXT NOT NULL,
                FOREIGN KEY(trackpicture) REFERENCES ANNpicture(pid),
                FOREIGN KEY(tracklabel) REFERENCES ANNlabel(lid),
                FOREIGN KEy(trackreviewer) REFERENCES ANNreviewer(rid) );

        INSERT INTO ANNlabel (labelname) values ('DEFAULT');
        INSERT INTO ANNreviewer (reviewername) values ('DEFAULT');
        """ )

        # Close stuff
        conn.commit()
        c.close()

    def addReviewer ( self, name ):
        rowid = -1
        try:
            conn = sqlite3.connect(self.dbFile)
            c = conn.cursor()

            c.execute ( "INSERT INTO ANNreviewer "
                    "(reviewername) values (?)", (name,) )
            rowid = c.lastrowid
        except sqlite3.IntegrityError as ie:
            # if it was not unique it was already there.
            if ( not str(ie).endswith("is not unique") ):
                raise Exception ("Could not insert reviewer")
        finally:
            conn.commit()
            c.close()

        return rowid

    def addPlot ( self, plid, pldesc = "" ):
        rowid = -1
        try:
            conn = sqlite3.connect ( self.dbFile )
            c = conn.cursor ()

            c.execute ( "INSERT INTO ANNplot "
                    "(plotid, plotdesc) values (?,?)", (plid, pldesc) )
            rowid = c.lastrowid
        except sqlite3.IntegrityError as ie:
            # if it was not unique it was already there.
            if ( not str(ie).endswith("is not unique") ):
                raise Exception ("Could not insert plot")
        finally:
            conn.commit()
            c.close()

        return rowid

    def addMetadata ( self, name, value ):
        rowid = -1
        try:
            conn = sqlite3.connect (self.dbFile)
            c = conn.cursor ()

            c.execute ( "INSERT INTO ANNmetadata "
                    "(mname, mvalue) values (?, ?)", (name, value) )
            rowid = c.lastrowid
        except sqlite3.IntegrityError as ie:
            # if it was not unique it was already there.
            if ( not str(ie).endswith("is not unique") ):
                raise Exception ("Could not insert metadata")
        finally:
            conn.commit()
            c.close()

        return rowid

    def addLabel ( self, lname ):
        rowid = -1
        try:
            conn = sqlite3.connect (self.dbFile)
            c = conn.cursor ()

            c.execute ( "INSERT INTO ANNlabel "
                "(labelname) values (?)", (lname,) )
            rowid = c.lastrowid
        except sqlite3.IntegrityError as ie:
            # if it was not unique it was already there.
            if ( not str(ie).endswith("is not unique") ):
                raise Exception ("Could not insert label")
        finally:
            conn.commit()
            c.close()

        return rowid

    def addPicturePlot ( self, phash, pfile, plot, isplotid ):
        rowid = -1

        # when it's not an id make sure its there
        if ( not isplotid ):
            plotRowID = self.isPlotInDB (plot)
            if ( plotRowID == -1 ):
                plotRowID = self.addPlot(plot)
        else:
            plotRowID = plot

        try:
            conn = sqlite3.connect (self.dbFile)
            c = conn.cursor()

            c.execute ( "INSERT INTO ANNpicture " \
                        "(phash, pfile, trackplot, pdate) values " \
                        "(?,?,?,datetime())", (phash, pfile, plotRowID) )
            rowid = c.lastrowid
        except sqlite3.IntegrityError as ie:
            if ( str(ie) is "column phash is not unique" ):
                raise Exception ( "Repeated image hash")
            else:
                raise Exception ( "Failed to add picture: %s", ie )
        finally:
            conn.commit()
            c.close()

        return rowid

    def addAnnotation ( self, picture, ispictureid,
                              label, islabelid,
                              reviewer, isreviewerid,
                              polygon ):
        rowid = -1
        # Create sql string.
        pictureidstr = "?"
        if ( not ispictureid ):
            # Use pfile if its a file, phas if its a hash.
            pictureidstr = \
                    "(SELECT pid FROM ANNpicture WHERE %s=?)" % \
                    "pfile" if (picture.find('.')!=-1) else "phash"

        labelidstr = "?"
        if ( not islabelid ):
            labelidstr = "(SELECT lid FROM ANNlabel WHERE labelname=?)"

        revieweridstr = "?"
        if ( not isreviewerid ):
            revieweridstr = \
                    "(SELECT rid FROM ANNreviewer WHERE reviewername=?)"

        sqlstr = "INSERT INTO ANNannotation " \
                "(trackpicture, tracklabel, trackreviewer, anndate, polygon ) \
                values (%s, %s, %s, datetime(), ?)" % \
                ( pictureidstr, labelidstr, revieweridstr )

        try:
            conn = sqlite3.connect (self.dbFile)
            c = conn.cursor()

            c.execute ( sqlstr, (picture, label, reviewer, polygon) )
            rowid = c.lastrowid
        except sqlite3.IntegrityError as ie:
            if ( str(ie) is "ANNannotation.trackpicture may not be NULL" ):
                raise Exception ("picture identifier %s does not exist" % \
                        picture )
            elif ( str(ie) is "ANNannotation.tracklabel may not be NULL" ):
                raise Exception ("label identifier %s does not exist" % label )
            elif ( str(ie) is "ANNannotation.trackreviewer may not be NULL" ):
                raise Exception ("label reviewer %s does not exist" % reviewer )
            else:
                raise Exception ("Failed to add annotation: %s" % ie)

        finally:
            conn.commit()
            c.close()

        return rowid

    def getMetadata ( self, name ):
        conn = sqlite3.connect(self.dbFile)
        c = conn.cursor()

        c.execute ( "SELECT mvalue from ANNmetadata "
                "WHERE mname=?;", (name,) )
        qres = c.fetchall()
        c.close()

        return qres[0][0]

    def isFileInDB ( self, hexstr ):
        rowid = -1
        conn = sqlite3.connect(self.dbFile)
        c = conn.cursor()
        c.execute ( "SELECT pid FROM ANNpicture WHERE phash=?", (hexstr,) )
        qres = c.fetchall()
        if ( len(qres) >= 1 ):
            rowid = qres[0][0]
        c.close()
        return rowid

    def isPlotInDB ( self, plotid ):
        rowid = -1
        conn = sqlite3.connect(self.dbFile)
        c = conn.cursor()
        c.execute ( "SELECT plid FROM ANNplot where plotID=?", (plotid,) )
        qres = c.fetchall()
        c.close()

        if ( len(qres) >= 1 ):
            rowid = qres[0][0]
        return rowid

    def isRevInDB (self, reviewer ):
        rowid = -1
        conn = sqlite3.connect(self.dbFile)
        c = conn.cursor()
        c.execute ("SELECT rid FROM ANNreviewer WHERE reviewername=?",
                (reviewer,) )
        qres = c.fetchall ()
        c.close()

        if ( len(qres) >= 1 ):
            rowid = qres[0][0]

        return rowid

#}}} AnnHandler

#{{{ImgHandler
class ImgHandler:
    # For the hash calculation
    step = 128 # 128 bytes
    numSteps = 70 # 8960 bytes equiv.

    def __init__ ( self, rootDir = '.' ):
        if not os.path.exists(rootDir):
            raise Exception("Root dir does not exist")

        self.rootDir = rootDir
        self.annDir = os.path.join(self.rootDir, ".ann")

        # Might exist or not depending on OS.
        self.ihLink = None
        try:
            self.ihLink = shutil.copy
            self.ihLink = os.link
        except:
            pass

    @classmethod
    def isImg ( cls, imgFile ):
        # Check for image. only with extensions.
        mtype = mimetypes.guess_type(imgFile)[0]
        if ( mtype is None or not mtype.startswith("image") ):
            return False
        return True

    @classmethod
    def calcHash ( cls, imgFile ):
        if ( not cls.isImg(imgFile) ):
            raise Exception ( "Incorrect image extension: %s" % imgFile )

        md5 = hashlib.md5()
        f = os.open (imgFile, os.O_RDONLY)

        for i in range (cls.numSteps):
            data = os.read(f, cls.step)
            if not data:
                break
            md5.update(data)
        os.close(f)

        return md5.hexdigest()

    @classmethod
    def getPlotIDFromExif (cls, imgFile ):
        return annexif.getPlotID(imgFile)

    def addImg ( self, img ):
        if ( img.__class__.__name__ != 'str' ):
            raise Exception ("Did not expect a non string")

        if ( not os.path.exists(img) ):
            raise Exception ("The file %s does not exist" % img )

        if ( not os.path.isfile(img) ):
            raise Exception ("%s does not point to a file" % img )

        if ( not self.isImg(img) ):
            raise Exception ("The file %s is not an image" % img )

        imgbn = os.path.basename(img) # image base name

        # Add to root dir
        rootdst = os.path.join(self.rootDir, imgbn)
        if ( not os.path.exists(rootdst) ):
            self.ihLink(os.path.abspath(img), rootdst)

        # Add to .ann dir
        anndst = os.path.join(self.annDir, imgbn)
        if ( not os.path.exists(anndst) ):
            self.ihLink(os.path.abspath(img), anndst)

#}}}ImgHandler

#{{{DataHandler
class DataHandler:
    def __init__(self, rootDir = "." ):
        if not os.path.exists(rootDir):
            raise Exception("Root dir %s does not exist"%rootDir)

        self.rootDir = rootDir
        self.annDir = os.path.join(self.rootDir, ".ann")
        if not os.path.exists(self.annDir):
            os.mkdir(self.annDir)

        self.ih = ImgHandler(rootDir=self.rootDir)
        self.ah = AnnHandler(rootDir=self.rootDir)

    # Create a database if on does not exist.
    def dbExists ( self ):
        return self.ah.dbExists()

    def initDB ( self ):
        self.ah.initDB ()

    def _addImage (self, imgPath ):
        #FIXME: both addPictrePlot and addImg throw exceptions.!!!!!
        imgHash = ImgHandler.calcHash (imgPath)
        imgPlotID = ImgHandler.getPlotIDFromExif (imgPath)

        imgbn = os.path.basename(imgPath) # image base name
        self.ah.addPicturePlot ( imgHash, imgbn, imgPlotID, False )
        self.ih.addImg (imgPath)

    def addImages ( self, fsElems ):
        if ( fsElems.__class__.__name__ is 'str' ):
            fsElems = [fsElems]

        # Create all the links.
        if ( not self.dbExists() ):
            self.initDB ()

        # Add images to FS and DB
        for fselem in fsElems:
            if ( os.path.exists (fselem) ):
                self._addImage (fselem)
            elif ( os.path.isdir (fselem) ):
                for subelem in os.listdir(fselem):
                    # We ignore the sub-directories.
                    tmpPath = os.path.join(fselem, subelem)
                    if ( os.path.exists(tmpPath) ):
                        self._addImage (tmpPath)

    def addReviewer ( self, name ):
        if ( not self.dbExists() ):
            raise Exception ("No database detected")

        # return rowid.
        return self.ah.addReviewer(name)

