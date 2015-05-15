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

def parse_knot(s):
    return s[0:s.find("(")]

def parse_knots(s):
    if s == "": return []
    return map(parse_knot,s.split(" "))

# unit tests for the parsing functions

def unit_test():
    assert(has_parent("X1")==False)
    assert(has_parent("X1s1")==True)
    assert(get_parent_pendant("X1s1")=="X1")
    assert(get_parent_pendant("X1s6s1")=="X1s6")
    assert(len(parse_knots("1S(5.0/Z) 2S(14.0/Z) 1E(25.0/Z)"))==3)
    assert(parse_knots("1S(5.0/Z) 2S(14.0/Z) 1E(25.0/Z)")[0]=="1S")
    assert(len(parse_knots(""))==0)

# run em...
unit_test()

# convert a database spreadsheet into a dot file for visualisation
def parse_to_dot(worksheet):
    out = "digraph {\n graph [rankdir=LR]\n"
    for curr_row in range(6,worksheet.nrows):
        row = worksheet.row(curr_row)
        pid = worksheet.cell_value(curr_row, 0)
        knots = worksheet.cell_value(curr_row, 3)

        if worksheet.cell_type(curr_row, 0)==2: # a number
            pid = str(int(pid))

        if not has_parent(pid):
            out+='"primary" -> "'+pid+'"\n'
        else:
            out+='"'+get_parent_pendant(pid)+'" -> "'+pid+'"\n'

        # stick the knots on the end
        p = pid
        for knot in parse_knots(knots):
            out+='"'+p+'" -> "'+pid+':'+knot+'"\n'
            p = pid+':'+knot
            out+='"'+p+'" [label="'+knot+'"style=filled, fillcolor=yellow]\n'

    out+="}\n"
    return out

# open the spreadsheet
workbook = xlrd.open_workbook('UR001.xls')
print workbook.sheet_names()
worksheet = workbook.sheet_by_name('Pendant Detail')

with open('khipu.dot', 'w') as f:
    f.write(parse_to_dot(worksheet))
