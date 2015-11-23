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

import sys
import os
import xlrd
from quipulib import *

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
        length = quipu.cell_value(curr_row, 4)
        if quipu.cell_type(curr_row, 4)==2: # convert a number to text
            length = str(length)
        colours = parse_colour(quipu.cell_value(curr_row, 7))
        value = quipu.cell_value(curr_row, 8)


        # generate graphviz colour list
        clist = ""
        for i,c in enumerate(colours):
            if i==0:
                clist+=c[1:-1]
            else:
                clist+=":"+c[1:-1]

        pendant_values = 'pendant_colors="'+clist+'", '+\
                         'pendant_ply="'+ply+'", '+\
                         'pendant_attach="'+attach+'", '+\
                         'pendant_length="'+length+'"'

        fontcolour = "#000000"
        if getLum(colours[0]) <= 100: fontcolour = "#ffffff"

        penwidth="5"
        if len(colours)>1: penwidth="2"

        # no parent, attach to the primary node
        parent = 'primary'
        if has_parent(pid):  parent=get_parent_pendant(pid)

        # describe the node details
        out+='"'+pid+'" [qtype="pendant_node", '+pendant_values+', label="'+ply+" "+attach+'", style=filled, fillcolor="'+clist+'", fontcolor="'+fontcolour+'"]\n'
        # connection to parent
        out += '"'+parent+'" -- "'+pid+'" [qtype="pendant_link",penwidth='+penwidth+',color="'+clist+'"]\n'

        # stick the knots on the end of the pendant node
        p = pid
        pos = 0
        for i,knot in enumerate(knots):
            kid = pid+':'+str(i)
            pos+=knot.position
            out+='"'+kid+'" [qtype="knot_node", '+knot.values()+', label="'+knot.render()+'", style=filled, fillcolor="'+clist+'" , fontcolor="'+fontcolour+'"]\n'
            out+='"'+p+'" -- "'+kid+'" [qtype="knot_link",penwidth='+penwidth+',color="'+clist+'"]\n'
            p = kid

    out+="}\n"
    return out


# create the dotfile
def run(filename):
    print filename
    # open the spreadsheet
    try:
        workbook = xlrd.open_workbook(filename)
        quipu = workbook.sheet_by_name('Pendant Detail')
    except Exception:
        print "problem"
        return False

    with open(filename+'.dot', 'w') as f:
        f.write(parse_to_dot(quipu))
    return True

def batch_generate_dot(filenames):
    for filename in filenames:
        if run(filename):
            os.system("dot "+filename+".dot -Tpng > "+filename+".png")

# are we the script that's being run?
if __name__ == "__main__":
    if sys.argv[1]=="batch":
        batch_generate_dot(generate_quipu_list())
    else:
        run(sys.argv[1])
