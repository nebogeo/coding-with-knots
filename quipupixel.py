#!/usr/bin/env python
# Quipu database to dot graphs
# Copyright (C) 2015 Dave Griffiths, Florian Zeeh
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

from PIL import Image
from PIL import ImageDraw
import numpy as np
from matplotlib import pyplot as plt

import sys
import os
import xlrd
from quipulib import *

_NUMERALS = '0123456789abcdefABCDEF'
_HEXDEC = {v: int(v, 16) for v in (x+y for x in _NUMERALS for y in _NUMERALS)}

def rgb(triplet):
    return _HEXDEC[triplet[0:2]], _HEXDEC[triplet[2:4]], _HEXDEC[triplet[4:6]]

def safe_plot(pixels,x,y,c):
    if x>0 and x<pixels.shape[1] and y>0 and y<pixels.shape[0]:
        pixels[y,x]=c


class pendant:
    def __init__(self,pid,ply,attach,knots,length,colours,value):
        self.pid = pid
        self.children = []
        self.ply = ply
        self.attach = attach
        self.knots = knots
        if length=="": self.length=0
        else: self.length = float(length)
        self.colours = []
        for c in colours:
            # convert to triples
            self.colours.append(rgb(c[2:-1]))
        self.value = value

    def add(self,child):
        self.children.append(child)

    def find(self,pid):
        if self.pid==pid: return self
        else:
            for p in self.children:
                f = p.find(pid)
                if f: return f
            return False

    def pprint(self,depth):
        out=""
        header=""
        pheader=""
        for i in range(0,depth-1): pheader+=" "
        for i in range(0,depth): header+=" "
        out+=pheader+"{ \n"
        out+=header+"\"id\": \""+self.pid+"\", \"ply\": \""+self.ply+"\", \"attach\": \""+self.attach+"\", \n"
        cc = ""
        for i,c in enumerate(self.colours):
              cc+="["+str(c[0])+", "+str(c[1])+", "+str(c[2])+"]"
              if i!=len(self.colours)-1: cc+=", "

        out+=header+"\"colours\": ["+cc+"],\n"

        if (len(self.knots)==0):
            out+=header+"\"knots\": [],"
        else:
            out+=header+"\"knots\": [\n"
            for i,k in enumerate(self.knots):
                out+=header+"{ \"value\": "+str(k.value)+", \"type\": \""+k.type+"\", \"position\": "+str(k.position)+", \"spin\": \""+k.spin+"\" }"
                if i==len(self.knots)-1: out+="\n"
                else: out+=",\n"
            out+=header+"],\n"

        if (len(self.children)==0):
            out+=header+"\"children\": []\n"
        else:
            out+=header+"\"children\": [\n"
            for i,p in enumerate(self.children):
                out+=p.pprint(depth+2)
                if i==len(self.children)-1: out+="\n"
                else: out+=",\n"

            out+=header+"]\n"
        out+=pheader+"}"
        return out

    def num_pendants(self):
        count = 1
        for p in self.children:
            count+=p.num_pendants()
        return count

    def longest_pendant(self,depth):
        length = self.length+depth*3
        for p in self.children:
            l = p.longest_pendant(depth+1)
            if l>length: length=l
        return length

    def render_data(self,pixels,x,y):
        for i in range(0,int(self.length)):
            safe_plot(pixels,x,y+i,self.colours[i%len(self.colours)])

        kcol = self.colours[0]
        for k in self.knots:
            i = int(k.position)
            v = 25+k.value*25
            c = (255,255,0)
            if k.type=="S": c = (v,0,0)
            if k.type=="L": c = (0,v,0)
            if k.type=="E": c = (0,0,v)
            safe_plot(pixels,x+1,y+i,c)

    def render(self,pixels,sx,x,y):
        self.render_data(pixels,x,y)
        sx = x # where we started from
        tx = sx
        for p in self.children:
            for i in range(tx,x+3):
                safe_plot(pixels,i,y+3,p.colours[i%len(p.colours)])
            x+=3
            tx+=3
            tx,x=p.render(pixels,tx,x,y+3)
        return (sx,x)


def prerender(primary,filename,store):
    h = int(primary.longest_pendant(0))+10
    w = primary.num_pendants()*3
    store[filename] = [0,0,w,h]


def render(primary,filename):
    h = int(primary.longest_pendant(0))+10;
    im = Image.new("RGB", (primary.num_pendants()*3,h), "black")

    pixels=np.array(im)
    primary.render(pixels,0,0,0)
#    plt.imshow(pixels)
#    plt.show()
#    im.putdata(pixels)

    image = Image.fromarray(np.uint8(pixels))
    d_usr = ImageDraw.Draw(image)
    qname = os.path.basename(filename)[:-4]
    d_usr = d_usr.text((0,h-10),qname,(100,100,100))

    #image.save("pixel/"+qname+".png")
    return image


# convert a database spreadsheet into a dot file for visualisation
def parse_to_pendant_tree(quipu):
    primary = pendant("primary","?","?",[],0,["\"#ffffff\""],0)

    # skip the gumpf at the top, start on the 6th line
    for curr_row in range(6,quipu.nrows):
        # get the stuff from the row
        pid = quipu.cell_value(curr_row, 0)
        if quipu.cell_type(curr_row, 0)==2: # convert a number to text
            pid = str(int(pid))
        ply = quipu.cell_value(curr_row, 1)
        attach = quipu.cell_value(curr_row, 2)
        knots = parse_knots(quipu.cell_value(curr_row, 3))
        length = quipu.cell_value(curr_row, 4)
        if quipu.cell_type(curr_row, 4)==2: # convert a number to text
            length = str(length)
        colours = parse_colour(quipu.cell_value(curr_row, 7))
        value = quipu.cell_value(curr_row, 8)

        p = pendant(pid,ply,attach,knots,length,colours,value)

        if has_parent(pid):
            ppid = get_parent_pendant(pid)
            parent=primary.find(ppid)
            if parent:
                parent.add(p)
            else:
                print("parent "+ppid+" not found!")
                primary.add(p)
        else:
            primary.add(p)


    return primary

def find_row(rows,w,maxw):
    for i,r in enumerate(rows):
        if (r+w)<maxw:
            rows[i]+=w+20
            return i
    rows.append(0)
    return len(rows)-1

def fit(store):
    # find widest
    widest = 0
    for r in store.values():
        if r[2]>widest:
            widest = r[2]
    widest=2000
    print widest
    rows = [0]
    for r in store.values():
        row = find_row(rows,r[2],widest)
        r[0]=rows[row]-r[2]
        r[1]=row*80

    return (widest,len(rows)*80)

# create the dotfile
def prerun(filename,store):
    # open the spreadsheet
    try:
        workbook = xlrd.open_workbook(filename)
        quipu = workbook.sheet_by_name('Pendant Detail')
    except Exception:
        print "problem"
        return False
    primary = parse_to_pendant_tree(quipu)
    prerender(primary,filename,store)
    return store


def run(filename):
    # open the spreadsheet
    try:
        workbook = xlrd.open_workbook(filename)
        quipu = workbook.sheet_by_name('Pendant Detail')
    except Exception:
        print "problem"
        return False

    primary = parse_to_pendant_tree(quipu)

    #f = open(filename+".json","w")
    #f.write(primary.pprint(0))
    #f.close()

    return render(primary,filename)

def batch_run(filenames):
    store = {}
    for filename in filenames:
        prerun(filename,store)

    size = fit(store)
    im = Image.new("RGB", size, "black")

    for filename in filenames:
        if filename in store:
            qim = run(filename)
            im.paste(qim,(store[filename][0],store[filename][1]))

    print(len(store))
    im.save("comp.png")

# are we the script that's being run?
if __name__ == "__main__":
    if sys.argv[1]=="batch":
        batch_run(generate_quipu_list())
    else:
        run(sys.argv[1])
