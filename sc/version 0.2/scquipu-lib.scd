

/*

SuperCollider functions for loading Quipu dotfile Datasets


*/


~parse_dicts = { |dict|
	var res = IdentityDictionary.new;
	dict.pairsDo { |key, val|
		var couldBeNumber;
		if(key.isString.not) { "not a string".warn; key.postcs; };
		key = key.asSymbol;

		switch(key,

			\colours, {
				val = val.collect { |triple| Color.new255(*triple.collect(_.asInteger)) }
			},

			\children, {
				val = val.collect { |dict| ~parse_dicts.(dict) }
			},

			\knots, {
				val = val.collect { |dict| ~parse_dicts.(dict) }
			},
			{
				val = if(~couldBe_NumberString.(val)) { val.asFloat } { val.asSymbol }
			}
		);
		res.put(key, val)
	};
	~traverse_tree.(res, { |each, parent| each[\parent] = parent });
	res
}.inEnvir;

~traverse_tree = { |dict, func, parent|
	dict[\children].do { |each| ~traverse_tree.(each, func, dict) };
	func.value(dict, parent);
}.inEnvir;


~couldBe_NumberString = { |val|
	val.isString and: {
			val.every({ |item, i|  // from wslib
			((item.isDecDigit) or: (item == $.))
			or: ((item == $-) && (i == 0))
		}) and: { this != "-" };
	};
}.inEnvir;  // the "inEnvir" message makes the scope ofthese functions local to the envir they are defined in


~load_data = ~parse_dicts <> { |path| path.parseYAMLFile };



/*

Information Theory

*/


~entropy = { |list|
	var histogram = list.as(Bag);
	var contributions = histogram.contents.values / list.size;
	contributions.sum { |c| neg(c) * log2(c) }
};



/*

Navigation

*/



// depth of the tree at a given pendant node
~find_level = { |dict|
		var parent = dict, level = 0;
		while {
			parent.notNil
		} {
			parent = ~find_parentPendant.(parent);
			level = level + 1
		};
		level
}.inEnvir;

~find_parentPendant = { |node|
		var parentLink;
		parentLink = ~all_links.select {|x| x[\value].value == node[\value] }[0];
		parentLink !? {
			~node_dict[parentLink[\value].key]
		}
}.inEnvir;



// untested functions //


~go_down = { |name, func, depth = 0|
		var step, all = ~all_links.select { |x| x[\value].key == name };
		func.value(name, depth);
		step = if(all.size > 1) { 1 } { 0 };
		all.do { |each|
			var name = each[\value].value;
			~go_down.(name, func, depth + step)
		};
}.inEnvir;


~find_up = { |node|
	var uplinks;
	var key = node[\value];

	if(node[\type] == \qlink) {
		uplinks = [node]
	} {
		uplinks = ~all_links.select { |x|
			x[\value].value == key;
		};
	};
	uplinks.collect { |x| ~node_dict[x[\value].key] }.unbubble;
}.inEnvir;


// untested!
~find_down = { |node|
		var links, key = node[\value];
		if(node[\type] == \qnode) {
			links = ~all_links.select { |x| x[\value].key == key };
			links.collect { |x| ~node_dict[x[\value].value] };
		} {
			[~node_dict[x[\value].value]];
		}
}.inEnvir;

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


