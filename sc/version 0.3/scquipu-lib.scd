
/*

SuperCollider functions for loading Quipu dotfile Datasets

version 0.3 based on the new json file format

NOTE: not all functions from previous versions have moved yet.


The json file is structured as follows:

each entry has a number of fields with properties, like ply ("S" or "Z"), colours (array of arrays), position (like 11.5).
It has also possibly an array of "children", which contains more entries.
It has possibly an array of "knots", which contains more entries.

*/

~readYaml = { |path|
	path.parseYAMLFile
};
~couldBeNumberString = { |val|
	val.isString and: {
			val.every({ |item, i|  // from wslib
			((item.isDecDigit) or: (item == $.))
			or: ((item == $-) && (i == 0))
		}) and: { this != "-" };
	};
};
~parseDicts = { |dict|
	var res = IdentityDictionary.new;
	dict.pairsDo { |key, val|
		var couldBeNumber;
		if(key.isString.not) { "not a string".warn; key.postcs; };
		key = key.asSymbol;

		switch(key,

			\colours, {
				val.postcs;
				val = val.collect { |triple| triple.collect(_.asInteger) } // convert to 0..1 range
			},

			\children, {
				val = val.collect { |dict| ~parseDicts.(dict) }
			},

			\knots, {
				val = val.collect { |dict| ~parseDicts.(dict) }
			},
			{
				val = if(~couldBeNumberString.(val)) { val.asFloat } { val.asSymbol }
			}
		);
		res.put(key, val)
	};
	res
};

~getQuipuData = ~parseDicts <>~readYaml;

/*

Information Theory

*/


~entropy = { |list|
	var histogram = list.as(Bag);
	var contributions = histogram.contents.values / list.size;
	contributions.sum { |c| neg(c) * log2(c) }
};



