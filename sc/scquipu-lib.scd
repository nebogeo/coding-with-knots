

/*

SuperCollider functions for loading Quipu dotfile Datasets

~loadFile populates:

~allNodes
~allLinks
~nodeDict // nodes are stored under their value


*/

~useEnvir = { |envir, func|
	if(envir.isNil, func, {
		envir.parent = currentEnvironment;
		envir.use(func)
	});
};


~loadFile = { |path, envir|
	var string, lines, body;
	File.use(path.resolveRelative, "r", { |f| string = f.readAllString });
	lines = string.split(Char.nl);

	~useEnvir.(envir, {

		// all nodes and links begin with the form "xyz" -> "abc" or "xyz"
		body = lines.select { |x| x.beginsWith("\"") };

		~everything = body.collect { |x| ~parse.(x) };

		~allLinks = ~everything.select { |x| x[\type] == \qlink };
		~allNodes = ~everything.select { |x| x[\type] == \qnode };
		~allPendants = ~allNodes.select {|x| x[\qtype] == \pendant_node };
		~allKnots = ~allNodes.select {|x| x[\qtype] == \knot_node };

		~nodeDict = ();
		~allNodes.do { |x| ~nodeDict[x[\value]] = x;  };

		~linkDict = ();
		~allLinks.do { |x| ~linkDict[x[\value]] = x;  };

		~danglingNodes =
		~allLinks.select { |x|
			~nodeDict[x[\value].key].isNil
		}.collect { |x| x[\value].key }.as(Set);

		~topLinks = ~allLinks.select { |x|
			x[\value].key == \primary
		};

		~topNodes = ~topLinks.collect { |x|
			~nodeDict[x[\value].value]
		};

		"\n\n\n******\nfinished reading. %\n".postf(path);
		"number of nodes in quipu '%': %\n".postf(path.basename, ~allNodes.size);

		"--- missing nodes: -----".postln;
		~danglingNodes.postln;

	});


};

~convert = { |x|
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

~unquote = { |x|
	x.replace("\"", "").replace(" ", "").asSymbol;
};

~splitConvert = { |x|
	x !? {
		x.split($,).collect { |x| ~convert.(x) }.unbubble;
	}
};

~parse = { |x|
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
			var key = ~unquote.(pair[0]);
			var value = ~splitConvert.(pair[1]);
			attr[key] = value;
		};
		leftPart = x[0..i-2];
	} {
		leftPart = x
	};
	if(isLink) {
		// links are associations
		attr[\value] = Association(~unquote.(leftPart[..linkIndex-1]), ~unquote.(leftPart[linkIndex+2..]));
	} {
		attr[\value] = ~unquote.(leftPart)
	};
};



~goDown = { |name, func, depth = 0|
	var step, all = ~allLinks.select { |x| x[\value].key == name };
	func.value(name, depth);
	step = if(all.size > 1) { 1 } { 0 };
	all.do { |each|
		var name = each[\value].value;
		~goDown.(name, func, depth + step)
	};
};




// untested functions //

~findParentPendant = { |node, envir|
	~useEnvir.(envir, {
		var parentLink;
		parentLink = ~allLinks.select {|x| x[\value].value == node[\value]}[0];
		parentLink !? {
			~nodeDict[parentLink[\value].key]
		}
	})
};

// depth of the tree at a given pendant node
~findLevel = { |node, envir|
	~useEnvir.(envir, {
		var parent = node, level = 0;
		while {
			parent.notNil
		} {
			parent = ~findParentPendant.(parent);
			level = level + 1
		};
		level
	})
};


~findUp = { |node|
	var links;
	var key = node[\value];
	if(node[\type] == \qnode) {
		links = ~allLinks.select { |x|
			x[\value].value == key;
		};
		links.collect { |x| ~nodeDict[x] };
	} {
		[~nodeDict[node[\value].key]];
	}
};



/*

~findNode = { |key, envir|
~nodeDict[key]
};
~findDown = { |node|
var key = node[\value];
if(node[\type] == \qnode) {
var links = ~allLinks.select { |x| x[\value].key == key };
links.collect { |x| ~findNode.(x[\value].value) };
} {
[~findNode.(node[\value].value)];
}
};
~findUp = { |node|
var key = node[\value];
if(node[\type] == \qnode) {
var links = ~allLinks.select { |x|
x[\value].value == key;
};
links.collect { |x| ~findNode.(x) };
} {
[~findNode.(node[\value].key)];
}
};

~asTree = { |nodes|
nodes.collect { |x, i|
if(x[\type] == \qlink) {
~asTree.(~findDown.(x))
} {
x
}
}
};
*/


