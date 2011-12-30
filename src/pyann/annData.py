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
import datetime

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
        Conn = sqlite3.connect(self.dbFile)
        C = Conn.cursor()
        C.executescript ( """
            PRAGMA foreign_keys = ON;
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

            create table ANNelement (
                eid INTEGER PRIMARY KEY,
                ecomment TEXT );

            create table ANNannotation (
                akey INTEGER PRIMARY KEY,
                trackelement INTEGER NOT NULL,
                trackpicture INTEGER NOT NULL,
                tracklabel INTEGER NOT NULL,
                trackreviewer INTEGER NOT NULL,
                anndate DATE NOT NULL,
                polygon TEXT NOT NULL,
                FOREIGN KEY(trackelement) REFERENCES ANNelement(eid),
                FOREIGN KEY(trackpicture) REFERENCES ANNpicture(pid),
                FOREIGN KEY(tracklabel) REFERENCES ANNlabel(lid),
                FOREIGN KEy(trackreviewer) REFERENCES ANNreviewer(rid) );

        INSERT INTO ANNlabel (labelname) values ('DEFAULT');
        INSERT INTO ANNreviewer (reviewername) values ('DEFAULT');
        """ )

        # Close stuff
        Conn.commit()
        C.close()

    def activate ( self ):
        self.conn = sqlite3.connect(self.dbFile)
        self.c = self.conn.cursor()

    def deactivate ( self ):
        self.conn.commit()
        self.c.close()

    def addReviewer ( self, name ):
        rowid = -1
        try:
            self.c.execute ( "INSERT INTO ANNreviewer "
                             "(reviewername) values (?)", (name,) )
            rowid = self.c.lastrowid
        except sqlite3.IntegrityError as ie:
            # if it was not unique it was already there.
            if ( not str(ie).endswith("is not unique") ):
                raise Exception ("Could not insert reviewer")

        return rowid

    def addPlot ( self, plid, pldesc = "" ):
        rowid = -1
        try:
            self.c.execute ( "INSERT INTO ANNplot "
                             "(plotid, plotdesc) values (?,?)", (plid, pldesc) )
            rowid = self.c.lastrowid
        except sqlite3.IntegrityError as ie:
            # if it was not unique it was already there.
            if ( not str(ie).endswith("is not unique") ):
                raise Exception ("Could not insert plot")

        return rowid

    def addMetadata ( self, name, value ):
        rowid = -1
        try:
            self.c.execute ( "INSERT INTO ANNmetadata "
                             "(mname, mvalue) values (?, ?)", (name, value) )
            rowid = self.c.lastrowid
        except sqlite3.IntegrityError as ie:
            # if it was not unique it was already there.
            if ( not str(ie).endswith("is not unique") ):
                raise Exception ("Could not insert metadata")

        return rowid

    def addLabel ( self, lname ):
        rowid = -1
        try:
            self.c.execute ( "INSERT INTO ANNlabel "
                             "(labelname) values (?)", (lname,) )
            rowid = self.c.lastrowid
        except sqlite3.IntegrityError as ie:
            # if it was not unique it was already there.
            if ( not str(ie).endswith("is not unique") ):
                raise Exception ("Could not insert label")

        return rowid

    def addElement ( self, comment="" ):
        rowid = -1
        try:
            self.c.execute ( "INSERT INTO ANNelement (ecomment) values (?)",
                    (comment,) )
            rowid = self.c.lastrowid
        except sqlite3.IntegrityError as ie:
            raise Exception ("Could not add element")
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
            self.c.execute ( "INSERT INTO ANNpicture " \
                             "(phash, pfile, trackplot, pdate) values " \
                             "(?,?,?,datetime())", (phash, pfile, plotRowID) )
            rowid = self.c.lastrowid
        except sqlite3.IntegrityError as ie:
            if ( str(ie) is "column phash is not unique" ):
                raise Exception ( "Repeated image hash")
            else:
                raise Exception ( "Failed to add picture: %s", ie )

        return rowid

    # Arguments are dictionaries: pic[id="12"]
    def addAnnotation(self, picture, label, reviewer, element, polygon):
        if picture.__class__.__name__ != 'dict' \
                or label.__class__.__name__ != 'dict' \
                or reviewer.__class__.__name__ != 'dict' \
                or element.__class__.__name__ != 'dict':
            raise Exception ( "Wrong argument types for addAnnotation." )

        rowid = -1

        # Create picture str
        picvalue = ""
        picstr = "?"
        if ( "id" in picture.keys() ):
            picvalue = picture["id"]
        elif ( "file" in picture.keys() ):
            picvalue = picture["file"]
            picstr = "(SELECT pid FROM ANNpicture WHERE pfile=?)"
        elif ( "hash" in picture.keys() ):
            picvalue = picture["hash"]
            picstr = "(SELECT pid FROM ANNpicture WHERE phash=?)"
        else:
            raise Exception("Error picture arg (%s) in addAnnotation"%picture)

        # Create label str
        labvalue = ""
        labstr = "?"
        if ( "id" in label.keys() ):
            labvalue = label["id"]
        elif ( "name" in label.keys() ):
            labvalue = label["name"]
            labstr = "(SELECT lid FROM ANNlabel WHERE labelname=?)"
        else:
            raise Exception("Error label arg (%s) in addAnnotation"%label)

        # Create reviewer str
        revvalue = ""
        revstr = "?"
        if ( "id" in reviewer.keys() ):
            revvalue = reviewer["id"]
        elif ( "name" in reviewer.keys() ):
            revvalue = reviewer["name"]
            revstr = "(SELECT rid FROM ANNreviewer WHERE reviewername=?)"
        else:
            raise Exception("Error reviewer arg (%s) in addAnnotation"%reviewer)

        # Create element str
        elevalue = ""
        elestr = "?"
        if ( "id" in element.keys() ):
            elevalue = element["id"]
        elif ( "new" in element.keys() ): # create a new row
            ecomm = ""
            if ( "comment" in element.keys() ):
                ecomm = element["comment"]
            elevalue = self.addElement ( comment=ecomm )

        # Create sql string
        sqlstr = "INSERT INTO ANNannotation (trackelement, trackpicture, " \
                                            "tracklabel, trackreviewer, " \
                                            "anndate, polygon )" \
                    "values (%s, %s, %s, %s, datetime(), ?)" % \
                    ( elestr, picstr, labstr, revstr )

        try:
            self.c.execute ( sqlstr, (elevalue, picvalue, labvalue, revvalue, polygon) )
            rowid = self.c.lastrowid
        except sqlite3.IntegrityError as ie:
            if ( str(ie) is "ANNannotation.trackpicture may not be NULL" ):
                raise Exception ("picture identifier %s does not exist" % \
                        picvalue )
            elif ( str(ie) is "ANNannotation.trackelement may not be NULL" ):
                raise Exception ("element identifier %s does not exist"% \
                        elevalue)
            elif ( str(ie) is "ANNannotation.tracklabel may not be NULL" ):
                raise Exception ("label identifier %s does not exist" % \
                        labvalue )
            elif ( str(ie) is "ANNannotation.trackreviewer may not be NULL" ):
                raise Exception ("label reviewer %s does not exist" % \
                        revvalue )
            else:
                raise Exception ("Failed to add annotation: %s" % ie)

        return rowid

    def getPictureListByDate (self):
        rows = []

        self.c.execute ( "SELECT ANNpicture.pid, ANNpicture.pfile, "
                                "ANNpicture.phash, ANNpicture.pdate, "
                                " ANNplot.plotID "
                        "FROM ANNpicture, ANNplot "
                        "WHERE ANNpicture.trackplot=ANNplot.plid "
                        "ORDER BY ANNpicture.pdate;" )
        rows = self.c.fetchall()
        return rows

    def getPictureListByPlotID (self):
        rows = []
        self.c.execute ( "SELECT ANNpicture.pid, ANNpicture.pfile, "
                                "ANNpicture.phash, ANNpicture.pdate, "
                                "ANNplot.plotID "
                        "FROM ANNpicture, ANNplot "
                        "WHERE ANNpicture.trackplot=ANNplot.plid "
                        "ORDER BY ANNplot.plotID;" )
        rows = self.c.fetchall()

        return rows

    def getMetadata ( self, name ):
        self.c.execute ( "SELECT mvalue from ANNmetadata "
                         "WHERE mname=?;", (name,) )
        qres = self.c.fetchall()
        return qres[0][0]

    def getRevList ( self ):
        retVal = []
        self.c.execute ( "SELECT * FROM ANNreviewer" )
        retVal = self.c.fetchall()
        return retVal

    def getLabelList ( self ):
        retVal = []
        self.c.execute ( "SELECT * FROM ANNlabel" )
        retVal = self.c.fetchall()
        return retVal

    def isFileInDB ( self, hexstr ):
        rowid = -1
        self.c.execute ( "SELECT pid FROM ANNpicture WHERE phash=?", (hexstr,) )
        qres = self.c.fetchall()
        if ( len(qres) >= 1 ):
            rowid = qres[0][0]
        return rowid

    def isPlotInDB ( self, plotid ):
        rowid = -1
        self.c.execute ( "SELECT plid FROM ANNplot where plotID=?", (plotid,) )
        qres = self.c.fetchall()

        if ( len(qres) >= 1 ):
            rowid = qres[0][0]
        return rowid

    def isRevInDB (self, reviewer ):
        rowid = -1
        self.c.execute ("SELECT rid FROM ANNreviewer WHERE reviewername=?",
                        (reviewer,) )
        qres = self.c.fetchall ()

        if ( len(qres) >= 1 ):
            rowid = qres[0][0]

        return rowid

    def isLabelInDB ( self, label ):
        rowid = 1
        self.c.execute ( "SELECT lid FROM ANNlabel WHERE labelname=?", (label,) )
        qres = self.c.fetchall()

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

    def _addImage ( self, imgPath ):
        #FIXME: both addPictrePlot and addImg throw exceptions.!!!!!
        imgHash = ImgHandler.calcHash (imgPath)
        imgPlotID = ImgHandler.getPlotIDFromExif (imgPath)

        imgbn = os.path.basename(imgPath) # image base name
        picid = self.ah.addPicturePlot ( imgHash, imgbn, imgPlotID, False )
        self.ih.addImg (imgPath)
        return picid

    def addImages ( self, fsElems ):
        if ( fsElems.__class__.__name__ is 'str' ):
            fsElems = [fsElems]

        # Create all the links.
        if ( not self.dbExists() ):
            self.initDB ()

        try:
            # Add images to FS and DB
            imgids = []
            self.ah.activate()
            for fselem in fsElems:
                if ( os.path.exists (fselem) ):
                    imgids.append( self._addImage (fselem) )
                elif ( os.path.isdir (fselem) ):
                    for subelem in os.listdir(fselem):
                        # We ignore the sub-directories.
                        tmpPath = os.path.join(fselem, subelem)
                        if ( os.path.exists(tmpPath) ):
                            imgids.append( self._addImage (tmpPath) )
        except:
            raise Exception("Could not complete the image addition")
        finally:
            self.ah.deactivate()

        return imgids

    def addReviewer ( self, name ):
        rowid = -1
        if ( not self.dbExists() ):
            raise Exception ("No database detected")

        # return rowid.
        try:
            self.ah.activate()
            rowid = self.ah.addReviewer(name)
        except:
            raise Exception("Could not add reviewer")
        finally:
            self.ah.deactivate()

        return rowid

    def addLabel ( self, label ):
        rowid = -1
        if ( not self.dbExists() ):
            raise Exception ("No database detected")

        # return rowid.
        try:
            self.ah.activate()
            rowid = self.ah.addLabel(label)
        except:
            raise Exception("Could not add label")
        finally:
            self.ah.deactivate()

        return rowid

    # Adds an annotation and creates a new element.
    def initAnn ( self, file, label, reviewer, polygon ):
        rowid = -1

        try:
            self.ah.activate()
            rowid = self.ah.addAnnotation ( {"file":file}, {"name":label},
                    {"name":reviewer}, {"new":"", "comment":"New Element"},
                    polygon )
        except:
            raise Exception ("Could not add annotation in addAnnotation")
        finally:
            self.ah.deactivate()

        return rowid


    def appendAnn ( self, img, label, reviewer, elemid, polygon ):
        rowid = -1

        try:
            self.ah.activate()
            rowid = self.ah.addAnnotation ( {"file":img}, {"name":label},
                    {"name":reviewer}, {"id":elemid}, polygon )
        except:
            raise Exception ("Could not add annotation in addAnnotation")
        finally:
            self.ah.deactivate()

        return rowid

    def getRevList (self):
        revList = []
        try:
            self.ah.activate()
            revList = self.ah.getRevList()
        except:
            raise Exception ("Could not retrieve rev list in getRevList")
        finally:
            self.ah.deactivate()

        return revList

    def getLabelList (self):
        labelList = []
        try:
            self.ah.activate()
            labelList = self.ah.getLabelList()
        except:
            raise Exception ("Could not retrieve label list in getLabelList")
        finally:
            self.ah.deactivate()

        return labelList

    def getPicListAndOffsetByDate ( self, date ):
        if date.__class__.__name__ != "datetime":
            raise Exception("I expected a datetime object")

        try:
            self.ah.activate()
            picList = self.ah.getPictureListByDate ()
        except:
            raise Exception("Could not retrieve pic list")
        finally:
            self.ah.deactivate()

        for offset in range(len(picList)):
            D = datetime.datetime.strptime( picList[offset][3],
                                            "%Y-%m-%d %H:%M:%S")
            if D > date:
                break

        return (offset, picList)

    def getPicListAndOffsetByPlotID (self, plotID ):
        if plotID.__class__.__name__ != "str":
            raise Exception("I expected a string object")

        try:
            self.ah.activate()
            picList = self.ah.getPictureListByPlotID ()
        except:
            raise Exception("Could not retrieve pic list")
        finally:
            self.ah.deactivate()

        for offset in range(len(picList)):
            if picList[offset][4] == plotID:
                break

        return (offset, picList)


    def isHashInDB ( self, imgHash ):
        retVal = False
        if imgHash.__class__.__name__ != "str":
            raise Exception("Expected a string in isHashInDB")

        try:
            self.ah.activate()
            retVal = self.ah.isFileInDB(imgHash) != -1
        except:
            raise Exception("Could not access DB in isHashInDB")
        finally:
            self.ah.deactivate()

        return retVal

    def isPlotInDB ( self, plotID ):
        retVal = False
        if plotID.__class__.__name__ != "str":
            raise Exception("Expected a string in isPlotInDB")

        try:
            self.ah.activate()
            retVal = self.ah.isPlotInDB(plotID) != -1
        except:
            raise Exception("Could not access DB in isPlotInDB")
        finally:
            self.ah.deactivate()

        return retVal

    def isRevInDB ( self, rev ):
        retVal = False
        if rev.__class__.__name__ != "str":
            raise Exception("Expected a string in isRevInDB")

        try:
            self.ah.activate()
            retVal = self.ah.isRevInDB(rev) != -1
        except:
            raise Exception("Could not access DB in isRevInDB")
        finally:
            self.ah.deactivate()

        return retVal

    def isLabelInDB ( self, label ):
        retVal = False
        if label.__class__.__name__ != "str":
            raise Exception("Expected a string in isLabelInDB")

        try:
            self.ah.activate()
            retVal = self.ah.isLabelInDB(label) != -1
        except:
            raise Exception("Could not access DB in isLabelInDB")
        finally:
            self.ah.deactivate()

        return retVal
