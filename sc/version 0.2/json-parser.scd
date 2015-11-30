


(
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
				val = val.collect { |triple| Color.new255(*triple.collect(_.asInteger)) }
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
~getQuipuData = ~parseDicts <>~readYaml
);




~data = ~getQuipuData.("UR007.xls.json".resolveRelative);
~data.cs; // post compile string

(
~traverse = { |dict, func|
	dict[\children].do { |each| ~traverse.(each, func) };
	func.value(dict);
}
);


~traverse.(~data, { |x| x[\colours].postln });
~traverse.(~data, { |x| x[\knots].postln });


