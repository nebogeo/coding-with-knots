#!/usr/bin/env python
# A Quipu database parser
# Copyright (C) 2015 Dave Griffiths
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

import sys
import xlrd
import math

# functions for parsing the string data

def has_parent(s):
    return s.find("s") != -1

def get_parent_pendant(s):
    if has_parent(s):
        return s[0:s.rfind("s")]
    else: return ""

# a knot is complicated enough to make a class for
class knot:
    def __init__(self,value,type,position,spin):
        self.value = value
        self.type = type
        self.position = position
        self.spin = spin

    # render the knot to ascii format!
    def render(self):
        direction = "?"
        # + 90 degrees
        if self.spin=="S": direction = "/"
        if self.spin=="Z": direction = "\\\\"

        r=""
        if self.type == "S":
            for i in range(0,self.value):
                if i==0:
                    r+="O"
                else:
                    r+=direction+"O"
        elif self.type == "L":
            r+="("
            for i in range(0,self.value):
                r+=direction
            r+=")"
        elif self.type == "E":
            r+=direction+"8"
        return r

# build a knot from it's text representation
def parse_knot(s):
    value = 1
    position = 0
    try:
        value = int(s[0:1])
        position = float(s[s.find("(")+1:s.find("/")])
    except Exception:
        print("error parsing knot: "+s)
    return knot(value,
                s[1:s.find("(")],
                position,
                s[s.find("/")+1:s.find(")")])

# render a list of knots
def parse_knots(s):
    if s == "": return []
    return map(parse_knot,s.split(" "))

# multicolour codes
# B-G twisted together (barber pole)
# B:G interspersed (mottled)
# B/G colour change with distance

# partially from here: http://tx4.us/nbs-iscc.htm
colour_lookup = {
    "W": "#777777",
    "SR":  "#BF2233",
    "MB" : "#673923",
    "GG" : "#575E4E",
    "KB" : "#35170C",
    "AB" : "#A86540",
    "HB" : "#5A3D30",
    "RL" : "#AA6651",
    "BG" : "#4A545C",
    "PG" : "#8D917A",
    "B" : "#7D512D",
    "0B" : "#64400F",
    "RM" : "#AB343A",
    "PR" : "#490005",
    "FR" : "#7F180D",
    "DB" : "#4D220E",
    "YB" : "#BB8B54",
    "MG" : "#817066",
    "GA" : "#503D33"
}

def parse_one_colour(s):
    if "(" in s: s = s[0:s.find("(")]
    s = s.strip(" ")

    if s in colour_lookup:
        return '"'+colour_lookup[s]+'"'
    else:
        if s!="":
            print("don't know this colour: ["+s+"]")
        return "yellow"

# we don't differenciate between colour effects yet :(
def parse_colour(s):
    #print s
    if ":" in s: return map(parse_one_colour,s.split(":"))
    elif "-" in s: return map(parse_one_colour,s.split("-"))
    elif "/" in s: return map(parse_one_colour,s.split("/"))
    else: return [parse_one_colour(s)]

# unit tests for the parsing functions
def unit_test():
    assert(has_parent("X1")==False)
    assert(has_parent("X1s1")==True)
    assert(get_parent_pendant("X1s1")=="X1")
    assert(get_parent_pendant("X1s6s1")=="X1s6")
    assert(len(parse_knots("1S(5.0/Z) 2S(14.0/Z) 1E(25.0/Z)"))==3)
    ks = parse_knots("1S(5.0/Z) 2S(14.0/Z) 1E(25.0/Z)")
    assert(ks[0].type=="S")
    assert(ks[0].position==5.0)
    assert(ks[0].spin=="Z")
    assert(len(parse_knots(""))==0)
    assert(parse_colour("foo")==["yellow"])
    assert(parse_colour("MB")==['"#673923"'])
    assert(parse_colour("MB:MG")==['"#673923"','"#817066"'])

# run em...
unit_test()

# convert a database spreadsheet into a dot file for visualisation
def parse_to_dot(quipu):
    out = "graph {\n graph [rankdir=LR]\n"
    # skip the gumpf at the top, start on the 6th line
    for curr_row in range(6,quipu.nrows):
        # get the stuff from the row
        pid = quipu.cell_value(curr_row, 0)
        if quipu.cell_type(curr_row, 0)==2: # convert a number to text
            pid = str(int(pid))
        ply = quipu.cell_value(curr_row, 1)
        attach = quipu.cell_value(curr_row, 2)
        knots = parse_knots(quipu.cell_value(curr_row, 3))
        colours = parse_colour(quipu.cell_value(curr_row, 7))

        # generate graphviz colour list
        clist = ""
        for i,c in enumerate(colours):
            if i==0:
                clist+=c
            else:
                clist+=":"+c

        # no parent, attach to the primary node
        if not has_parent(pid):
            out+='"primary" -- "'+pid+'" [penwidth=1,color='+colours[0]+']\n'
        else:
            # otherwise attach to parent
            out+='"'+get_parent_pendant(pid)+'" -- "'+pid+'" [penwidth=1,color='+colours[0]+']\n'

        # describe the node details
        # customize threshold. bright white should be 255  
        if(getLum(colours[0]) <= 100 and colours[0] != "yellow"):
            out+='"'+pid+'" [label="'+ply+" "+attach+'", style=filled, fillcolor='+colours[0]+', fontcolor="#FFFFFF"'+']\n'
        else:
            out+='"'+pid+'" [label="'+ply+" "+attach+'", style=filled, fillcolor='+colours[0]+']\n'

        # stick the knots on the end of the pendant node
        p = pid
        pos = 0
        for i,knot in enumerate(knots):
            kid = pid+':'+str(i)
            out+='"'+p+'" -- "'+kid+'" [penwidth=1,color='+colours[0]+']\n'
            pos+=knot.position
            # print getLum(colours[0])
            if(colours[0] != "yellow" and getLum(colours[0]) <= 100):
               # print "++++++++ it's getting white"
                out+='"'+kid+'" [label="'+knot.render()+'", style=filled, fillcolor='+colours[0]+', fontcolor="#FFFFFF"'+']\n'
            else:
               # print "-------- it's the same as it is"
                out+='"'+kid+'" [label="'+knot.render()+'", style=filled, fillcolor='+colours[0]+']\n'
            p = kid

    out+="}\n"
    return out

def getLum(hex_color):
#    print hex_color
#    print "/////////// it should get white"
    if hex_color != "yellow":
        rgb_int = int("0x" + str(hex_color)[2:-1], 0)
        blue = rgb_int & 255
        green = (rgb_int >> 8) & 255
        red = (rgb_int >> 16) & 255
        lum = math.sqrt((0.299 * (red ** 2)) + (0.587 * (green **2)) + ( 0.144 * (blue**2)))
        return int(lum)
    else: 
        return hex_color

# open the spreadsheet
workbook = xlrd.open_workbook(sys.argv[1])
quipu = workbook.sheet_by_name('Pendant Detail')

with open(sys.argv[1]+'.dot', 'w') as f:
    f.write(parse_to_dot(quipu))
