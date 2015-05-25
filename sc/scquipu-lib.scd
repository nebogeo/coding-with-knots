

/*

SuperCollider functions for loading Quipu dotfile Datasets

~loadFile populates:

~allNodes
~allLinks
~nodeDict


*/

~loadFile = { |path|
	var string, lines;
	File.use(path.resolveRelative, "r", { |f| string = f.readAllString });
	lines = string.split(Char.nl);
	// all nodes and links begin with the form "xyz" -> "abc" or "xyz"
	~body = lines.select { |x| x.beginsWith("\"") };

	~allNodes = ~body.collect { |x| ~parse.(x) };
	~nodeDict = ();
	~allNodes.do { |x| if(x[\type] == \qnode) { ~nodeDict[x[\value]] = x } };
	~allLinks = ~allNodes.select { |x| x[\type] == \qlink };

	~findDangling = {
		~allNodes.select { |x| x[\type] == \qlink }.select { |x|
			~nodeDict[x[\value].key].isNil
		}.collect { |x| x[\value].key }.as(Set)
	};

	"--- missing nodes: -----".postln;
	~findDangling.value.postln;
};

~convert = { |x| // from wslib
	var couldBeNumber = x.every({ |item, i|
		((item.isDecDigit) or: (item == $.))
		or: ((item == $-) && (i == 0))
	}) and: { this != "-" };
	if(couldBeNumber) { x.interpret } { x.replace("\"", "").replace(" ", "").asSymbol }
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
			var key = ~convert.(pair[0]);
			var value = ~convert.(pair[1]);
			attr[key] = value;
		};
		leftPart = x[0..i-2];
	} {
		leftPart = x
	};
	if(isLink) {
		// links are associations
		attr[\value] = Association(~convert.(leftPart[..linkIndex-1]), ~convert.(leftPart[linkIndex+2..]));
	} {
		attr[\value] = ~convert.(leftPart)
	};
};

~findNode = { |key|
	//~allNodes.select { |x| x[\type] == \qnode and: { x[\value] == key } }
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
		var links = ~allNodes.select { |x|
			x[\type] == \qlink and: {
				x[\value].value == key;
			}
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


