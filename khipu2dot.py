# A Khipu database parser
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

import xlrd

# functions for parsing the string data

def has_parent(s):
    return s.find("s") != -1

def get_parent_pendant(s):
    if has_parent(s):
        return s[0:s.rfind("s")]
    else: return ""

class knot:
    def __init__(self,value,type,position,spin):
        self.value = value
        self.type = type
        self.position = position
        self.spin = spin

    def render(self):
        r = ""
        if self.type == "S":
            for i in range(0,self.value):
                if i==0:
                    r+="O"
                else:
                    r+="-O"
        elif self.type == "L":
            for i in range(0,self.value):
                r+="C"
        elif self.type == "E":
            r+="8"
        return r

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

def parse_knots(s):
    if s == "": return []
    return map(parse_knot,s.split(" "))

# colours

# multicolour codes
# B-G twisted together (barber pole)
# B:G interspersed (mottled)
# B/G colour change with distance

colour_lookup = {
    "W": "#FFFFFF",
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

def parse_colour(s):
    if ":" in s: s = s[0:s.find(":")]
    if "-" in s: s = s[0:s.find("-")]
    if "/" in s: s = s[0:s.find("/")]

    if "(" in s: s = s[0:s.find("(")]
    s = s.strip(" ")

    if s in colour_lookup:
        return '"'+colour_lookup[s]+'"'
    else:
        if s!="":
            print("don't know this colour: ["+s+"]")
        return "yellow"


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
    assert(parse_colour("foo")=="yellow")
    assert(parse_colour("MB")=='"#673923"')

# run em...
unit_test()

# convert a database spreadsheet into a dot file for visualisation
def parse_to_dot(quipu):
    out = "digraph {\n graph [rankdir=LR]\n"
    for curr_row in range(6,quipu.nrows):
        row = quipu.row(curr_row)
        pid = quipu.cell_value(curr_row, 0)
        knots = parse_knots(quipu.cell_value(curr_row, 3))
        colour = parse_colour(quipu.cell_value(curr_row, 7))

        if quipu.cell_type(curr_row, 0)==2: # a number
            pid = str(int(pid))

        if not has_parent(pid):
            out+='"primary" -> "'+pid+'"\n'
        else:
            out+='"'+get_parent_pendant(pid)+'" -> "'+pid+'"\n'

        out+='"'+pid+'" [label="", style=filled, fillcolor='+colour+']\n'

        # stick the knots on the end
        p = pid
        pos = 0
        for i,knot in enumerate(knots):
            kid = pid+':'+str(i)
            out+='"'+p+'" -> "'+kid+'"\n'
            pos+=knot.position
            out+='"'+kid+'" [label="'+knot.render()+'"style=filled, fillcolor='+colour+']\n'

    out+="}\n"
    return out

# open the spreadsheet
workbook = xlrd.open_workbook('UR035.xls')
print workbook.sheet_names()
quipu = workbook.sheet_by_name('Pendant Detail')

with open('khipu.dot', 'w') as f:
    f.write(parse_to_dot(quipu))
