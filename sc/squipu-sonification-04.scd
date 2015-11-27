// load the library
(
currentEnvironment = (); // make local
loadRelative("scquipu-lib.scd");
~data = currentEnvironment;
)


loadRelative("auto-quipu.scd").unbubble.("../data/xl/UR046.xls.dot");
loadRelative("auto-quipu.scd").unbubble.("../data/xl/UR019.xls.dot");


//
// (
// var f = loadRelative("auto-quipu.scd").unbubble;
// pathMatch("../data/xl/*.dot").do { |x|
// 	f.(x);
// };



// load one of the following data sets:
~load_file.("../data/more/dot/UR004.xls.dot");
~load_file.("../data/more/dot/HP019.xls.dot");
~load_file.("../data/xl/UR019.xls.dot");


// boring quipu
~load_file.("../data/xl/UR046.xls.dot");

// entropy-rich quipu
~load_file.("../data/xl/UR087.xls.dot");


// astronomical quipu
~load_file.("../data/xl/UR006.xls.dot");
~load_file.("../data/xl/UR009.xls.dot");

// variants of administrative quipus
~load_file.("../data/xl/UR066.xls.dot");
~load_file.("../data/xl/UR067.xls.dot");
~load_file.("../data/xl/UR068.xls.dot");


(
~top_pendants = ~top_links.collect { |x|
	~data.node_dict[x[\value].value]
};

)


// inka telefax
(
Tdef(\x, {
	~data.top_pendants.do { |x|
		var color = x[\fillcolor], note;
		x[\value].postln;
		if(color != nil and: color != \yellow) {
			note =  [color.red, color.green, color.blue] * 32;
			(note:note, sustain: 0.6, instrument: \sin).play;
		};
		0.1.wait;
	}
}).play
)

nil.class


~entropy.(~all_nodes.collect { |x| x[\fillcolor] })



// juan claude shannotl
(
Tdef(\x, {
	~data.top_pendants.do { |x|
		var colours, entropy;
		~go_down.(x[\value], { |id| colours = colours.add(~node_dict[id][\fillcolor]) });
		entropy = ~entropy.(colours);
		(note: entropy * 10, sustain: 0.2, instrument: \sin).play;
		0.01.wait;
	};
}).play
)

// juan claude shannotl
(
Tdef(\x, {
	var key;

	key = \pendant_ply;

	~data.top_pendants.do { |x|
		var items, entropy;
		~go_down.(x[\value], { |id| items = items.add(~node_dict[id][key]) });
		items = items.select { |x| x.notNil };
		entropy = ~entropy.(items);
		(note: entropy * 20, sustain: 0.2, instrument: \sin).play;
		0.01.wait;
	};
}).play
)

// juan claude shannotl looking into pendant_length
(
Tdef(\x, {
	var key;

	key = \pendant_length;

	~data.top_pendants.do { |x|
		var items, entropy;
		~go_down.(x[\value], { |id| items = items.add(~node_dict[id][key]) });
		items = items.select { |x| x.notNil };
		entropy = ~entropy.(items);
		(note: entropy * 20, sustain: 0.2, instrument: \sin).play;
		0.05.wait;
	};
}).play
)

~all_pendants[0].keys

(
~data.top_pendants.collect { |x|
	var key = \pendant_length;
	var items, entropy;
	~go_down.(x[\value], { |id| items = items.add(~node_dict[id][key]) });
	items = items.select { |x| x.notNil };
	//~entropy.(items);

};
)







// modulations for sub-pendants
(
Tdef(\x, {
	~go_down.(\primary, { |name, depth|
		var node, attribute, note, dur;
		node = ~data.node_dict[name];
		if(node.notNil) {
			dur = ((2/3 ** depth) * 0.2);
			//dur = 0.1;
			attribute = 0; //attribute[\];
			//var color = node[\fillcolor];
			if(attribute.notNil) {
				note =  attribute * 2; // + ([color.red, color.green, color.blue] * 5);
				(degree: attribute, mtranspose: depth, sustain: dur, instrument: \sin).play;
			};
			dur.wait;
		}
	})
}).play
)


// modulations for sub-pendants
(
Tdef(\x, {
	~go_down.(\primary, { |name, depth|
		var node, attribute, note, dur;
		node = ~data.node_dict[name];
		if(node.notNil) {
			dur = ((2/3 ** depth) * 0.2);
			//dur = 0.1;
			attribute = node[\fillcolor];
			if(attribute.notNil) {
				note = (attribute.red * 5).round;
				(degree: note, mtranspose: depth * 2, sustain: dur * 2, instrument: \sin).play;
			};
			dur.wait;
		}
	})
}).play
)


// modulations for sub-pendants
(
Tdef(\x, {
	~go_down.(\primary, { |name, depth|
		var node, attribute, note, dur;
		node = ~data.node_dict[name];
		if(node.notNil) {
			dur = ((2/3 ** depth) * 0.2);
			//dur = 0.1;
			attribute = node[\knot_value];
			if(attribute.notNil) {
				note = attribute;
				(degree: note, mtranspose: depth * 2, sustain: dur * 4, instrument: \sin).play;
			};
			dur.wait;
		}
	})
}).play
)



(
SynthDef(\sin, { |out, freq = 440, sustain = 1, pan, amp = 0.1, ply|
	var attack = ply.linlin(0, 1, Rand(0.1, 0.2), 1) * sustain;
	var release = ply.linlin(0, 1, 1, 0.01) * sustain;
	var env = EnvGen.ar(Env.perc(attack, release, amp * 3), doneAction:2);
	var son = SinOsc.ar(freq, SinOsc.ar(freq * 5) * 0.1);
	OffsetOut.ar(out, Pan2.ar(son, pan, env * AmpCompA.kr(freq)));
}).add;
)

