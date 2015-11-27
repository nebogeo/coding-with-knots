#!/usr/bin/env python
# Quipu database to entropy
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
import entropy
import operator
from quipulib import *
from quipu2dot import *

# maximise 'native' entropy
# todo: try filtering
def parse_to_raw(quipu):
    out = ""
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

        pendant_values = clist+ply+attach+length+clist
        # describe the node details
        out+=pid+pendant_values;

        for i,knot in enumerate(knots):
            out+=str(knot.value)
            out+=knot.type
            out+=str(knot.position)
            out+=knot.spin

    return out

def calculate_entropy(filename,encode_fn):
    print filename
    # open the spreadsheet
    try:
        workbook = xlrd.open_workbook(filename)
        quipu = workbook.sheet_by_name('Pendant Detail')
    except Exception:
        print "problem"
        return False

    print(encode_fn(quipu))
    return entropy.calc(encode_fn(quipu))

def batch_generate_entropy(filenames):
    cache = {}
    for filename in filenames:
        e = calculate_entropy(filename, parse_to_raw)
        if e!=False:
            cache[filename]=e

    sorted_cache = sorted(cache.items(), key=operator.itemgetter(1))
    for item in sorted_cache:
        print(item)

# are we the script that's being run?
if __name__ == "__main__":
    if sys.argv[1]=="test":
        print entropy.calc(sys.argv[2])
        exit(1)
    if sys.argv[1]=="batch":
        batch_generate_entropy(generate_quipu_list())
    else:
        print("entropy is: "+str(calculate_entropy(sys.argv[1], parse_to_raw)))
