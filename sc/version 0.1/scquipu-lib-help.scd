/*

Some documentation of the functions defined in the scquipu-lib

A quipu has pendants and knots, some of which also have their own pendants branching off.

*/

// load the library
// load the library
(
currentEnvironment = (); // make local
loadRelative("scquipu-lib.scd");
~data = currentEnvironment;
)


/*

this defines the following function

~load_file.(path, envir)

load a dot file (written by quipu2dot.py).

arguments:
# path - file path. the files are to be found in the "dotfiles" folder
# envir - if an envir is given, all data is kept in it. This allows you to keep several instances at once. If not given, the data is written into the currentEnvironment

*/


~load_file.("../data/xl/UR019.xls.dot");
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

~load_files provides the following things:

*/

// ~node_dict is a dictionary of all nodes (excluding links)

~data.node_dict; // all nodes accessible by id
~data.node_dict.keys.do { |key| key.postln }; // these are the ids, as given in the literature
~data.node_dict.values.collect { |x| x[\qtype] }.as(Set); // all qtypes

// ~link_dict dictionary of all nodes (excluding links)
~data.link_dict // all links accessible by id
~data.link_dict.keys.do { |key| key.postln }; // these are the ids: associations between node ids
~data.link_dict.values.collect { |x| x[\qtype] }.as(Set); // all qtypes

// ~all_pendants is an array of all nodes that are pendants (threads)
~data.all_pendants;

// ~all_knots is an array of all nodes that are knots.
~data.all_knots;

// ~all_entries is an array of all data points.
~data.all_entries

// ~top_nodes are the nodes connected to the long primary chord
~data.top_nodes;
~data.top_nodes.size;


// you can derive all data enries like this:
~allKnotData = ~data.node_dict.values.select { |x| x[\qtype] == \knot_node }.flopDict.collect(_.as(Set));
~allKnotData.keys // all entry fields
~allKnotData[\knot_position] // e.g. all existing knot positions
~allKnotData[\knot_type] // e.g. all existing knot types etc.


/*

the function ~go_down lets you traverse downward, starting from a given id.
The function is called with two arguments:
	# name of the respective node
	# recursion depth in which you currently are

*/

~go_down.(\primary, { |x, depth| [x, depth].postln });
~go_down.('4', { |x, depth| [x, depth].postln });


