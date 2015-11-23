

/*

SuperCollider functions for loading Quipu dotfile Datasets

~load_file populates:

~all_nodes
~all_links
~node_dict // nodes are stored under their value


*/

~use_envir = { |envir, func|
	if(envir.isNil, func, {
		envir.parent = currentEnvironment;
		envir.use(func)
	});
};


~load_file = { |path, envir|
	var string, lines, body;
	File.use(path.resolveRelative, "r", { |f| string = f.readAllString });
	lines = string.split(Char.nl);

	~use_envir.(envir, {

		// all nodes and links begin with the form "xyz" -> "abc" or "xyz"
		body = lines.select { |x| x.beginsWith("\"") };

		~all_entries = body.collect { |x| ~parse_dotfile.(x) };

		~all_links = ~all_entries.select { |x| x[\type] == \qlink };
		~all_nodes = ~all_entries.select { |x| x[\type] == \qnode };
		~all_pendants = ~all_nodes.select {|x| x[\qtype] == \pendant_node };
		~all_knots = ~all_nodes.select {|x| x[\qtype] == \knot_node };

		~node_dict = ();
		~all_nodes.do { |x| ~node_dict[x[\value]] = x;  };

		~link_dict = Dictionary.new; // reproduced associations are not identical
		~all_links.do { |x| ~link_dict[x[\value]] = x;  };

		~dangling_nodes =
		~all_links.select { |x|
			~node_dict[x[\value].key].isNil
		}.collect { |x| x[\value].key }.as(Set);

		~top_links = ~all_links.select { |x|
			x[\value].key == \primary
		};

		~top_nodes = ~top_links.collect { |x|
			~node_dict[x[\value].value]
		};

		"\n\n\n******\nfinished reading. %\n".postf(path);
		"number of nodes in quipu '%': %\n".postf(path.basename, ~all_nodes.size);

		"--- missing nodes: -----".postln;
		~dangling_nodes.postln;

	});

	envir
};

~convert_string = { |x|
	var couldBeNumber, isColor;
	// in case we later want to encode data with spaces, need to change this.
	x = x.replace(" ", "");
	x = x.replace("\"", "");
	couldBeNumber = x.every({ |item, i|  // from wslib
		((item.isDecDigit) or: (item == $.))
		or: ((item == $-) && (i == 0))
	}) and: { this != "-" };
	// in this case color is the only hexcode #54f523
	isColor = x.beginsWith("#");
	//[\isColor, isColor, \couldBeNumber, couldBeNumber].postln;
	//x.postcs;
	if(x == "yellow") {
		isColor = true;
		x = "#00FF00";
	};
	if(isColor) {
		Color.fromHexString(x)
	} {
		if(couldBeNumber) { x.interpret } { x.asSymbol }
	}
};

~unquote_string = { |x|
	x.replace("\"", "").replace(" ", "").asSymbol;
};

~split_convert = { |x|
	x !? {
		x.split($,).collect { |x| ~convert_string.(x) }.unbubble;
	}
};

~parse_dotfile = { |x|
	var i, j, attr = (), leftPart, rightPart;
	var linkIndex = x.find("--");
	var isLink = linkIndex.notNil;
	attr[\type] = if(isLink) { \qlink } { \qnode };
	i = x.find("[");
	if(i.notNil) {
		j = x.find("]", offset: i);
		rightPart = x[i+1..j-1];
		rightPart.split($,).do { |a|
			var pair = a.split($=);
			var key = ~unquote_string.(pair[0]);
			var value = ~split_convert.(pair[1]);
			attr[key] = value;
		};
		leftPart = x[0..i-2];
	} {
		leftPart = x
	};
	if(isLink) {
		// links are associations
		attr[\value] = Association(~unquote_string.(leftPart[..linkIndex-1]), ~unquote_string.(leftPart[linkIndex+2..]));
	} {
		attr[\value] = ~unquote_string.(leftPart)
	};
};



/*

Navigation

*/



// depth of the tree at a given pendant node
~find_level = { |node, envir|
	~use_envir.(envir, {
		var parent = node, level = 0;
		while {
			parent.notNil
		} {
			parent = ~find_parentPendant.(parent, envir);
			level = level + 1
		};
		level
	})
};

~find_parentPendant = { |node, envir|
	~use_envir.(envir, {
		var parentLink;
		parentLink = ~all_links.select {|x| x[\value].value == node[\value] }[0];
		parentLink !? {
			~node_dict[parentLink[\value].key]
		}
	})
};



// untested functions //


~go_down = { |envir, name, func, depth = 0|
	~use_envir.(envir, {
		var step, all = ~all_links.select { |x| x[\value].key == name };
		func.value(name, depth);
		step = if(all.size > 1) { 1 } { 0 };
		all.do { |each|
			var name = each[\value].value;
			~go_down.(envir, name, func, depth + step)
		};
	})
};


~find_up = { |node, envir|
	~useEnvir.(envir, {
		var links;
		var key = node[\value];
		if(node[\type] == \qnode) {
			links = ~all_links.select { |x|
				x[\value].value == key;
			};
			links.collect { |x| ~node_dict[x] };
		} {
			[~node_dict[node[\value].key]];
		}
	})
};

~find_down = { |node, envir|
	~useEnvir.(envir, {
		var links, key = node[\value];
		if(node[\type] == \qnode) {
			links = ~all_links.select { |x| x[\value].key == key };
			links.collect { |x| ~node_dict[x[\value].value] };
		} {
			[~node_dict[x[\value].value]];
		}
	})
};

/*



~find_up = { |node|
var key = node[\value];
if(node[\type] == \qnode) {
var links = ~all_links.select { |x|
x[\value].value == key;
};
links.collect { |x| ~find_node.(x) };
} {
[~find_node.(node[\value].key)];
}
};

*/


