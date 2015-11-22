/*

Some documentation of the functions defined in the scquipu-lib

A quipu has pendants and knots, some of which also have their own pendants branching off.

*/

// load the library
loadRelative("scquipu-lib.scd");


/*

this defines the following function

~loadFile.(path, envir)

load a dot file (written by quipu2dot.py).

arguments:
# path - file path. the files are to be found in the "dotfiles" folder
# envir - if an envir is given, all data is kept in it. This allows you to keep several instances at once. If not given, the data is written into the currentEnvironment

*/

~data = ();
~loadFile.("../data/xl/UR006.xls.dot", ~data);
~data
~data.keys // these are the fields generated

/*
Each data entry has the following fields.

--type--	\qlink (for a link between nodes) or \qnode (for a node, i.e. a knot or a pendant)
--qtype--	\pendant_node or \knot_node
--value--   this is the id according to archeological data. for qlinks, this is an association between two ids

Then a number of arguments, which are related to the dot file visualisation

style
fillcolor
label


Further archeological data:

--for knots--
knot_type
knot_position
knot_value
knot_spin


--for pendants--
pendant_length
pendant_ply
pendant_attach
pendant_colors


*/


/*

~loadFiles provides the following things:

*/

// ~nodeDict is a dictionary of all nodes (excluding links)

~data.nodeDict; // all nodes accessible by id
~data.nodeDict.keys.do { |key| key.post; " ".post }; // these are the ids, as given in the literature
~data.nodeDict.values.collect { |x| x[\qtype] }.as(Set); // all qtypes

// ~linkDict dictionary of all nodes (excluding links)
~data.linkDict // all links accessible by id
~data.linkDict.keys.do { |key| key.post; " ".post }; // these are the ids: associations between node ids
~data.linkDict.values.collect { |x| x[\qtype] }.as(Set); // all qtypes

// ~allPendants is an array of all nodes that are pendants (threads)
~data.allPendants;

// ~allKnots is an array of all nodes that are knots.
~data.allKnots;

// ~everything is an array of all data points.
~data.everything

// you can derive all data enries like this:
~allKnotData = ~data.nodeDict.values.select { |x| x[\qtype] == \knot_node }.flopDict.collect(_.as(Set));
~allKnotData.keys // all entry fields
~allKnotData[\knot_position] // e.g. all existing knot positions
~allKnotData[\knot_type] // e.g. all existing knot types etc.






