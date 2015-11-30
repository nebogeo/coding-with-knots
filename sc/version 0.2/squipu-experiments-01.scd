

// load the library
(
currentEnvironment = (); // make local
loadRelative("scquipu-lib.scd");
~data = currentEnvironment;
)



/*
we need the json files first, so the below doesn't work yet.
*/


// load one of the following data sets:
~data = ~load_file.("../data/more/dot/UR004.xls.dot");
~data = ~load_file.("../data/more/dot/HP019.xls.dot");
~data = ~load_file.("../data/xl/UR019.xls.dot");


// boring quipu
~data = ~load_file.("../data/xl/UR046.xls.dot");


// astronomical quipu
~data = ~load_file.("../data/xl/UR006.xls.dot");
~data = ~load_file.("../data/xl/UR009.xls.dot");

// variants of administrative quipus
~data = ~load_file.("../data/xl/UR066.xls.dot");
~data = ~load_file.("../data/xl/UR067.xls.dot");
~data = ~load_file.("../data/xl/UR068.xls.dot");

(
~all_pendants = { |dict|
	var all;
	~traverse_tree.(dict, { |x| all = all.add(x) });
	all
};
)

~all_pendants.(~data).collect { |x| x[\ply] };
~all_pendants.(~data).collect { |x| x[\knot_position] }; // nil ...
~all_pendants.(~data).collect { |x| x.class }.as(Set) // IdentityDictionary



(
~range_of = { |parameter|
	var all = ~all_pendants.(~data);
	var t = { |f| try(f, { "could not get one of the parameters: % ".format(parameter).warn }) };
	parameter.asArray.collect {|p|
		[
			all.minItem { |x| f.(x[p]) ? inf }[p],
			all.maxItem { |x| f.(x[p]) ? -inf }[p]
		]
	}.unbubble
};
~all_values_of = { |parameter|
	var all = ~all_pendants.(~data);
	parameter.asArray.collect {|p|
		all.collect { |x| x[p] }.reject { |x| x.isNil }.as(Set).as(Array).sort
	}.unbubble
};
)

~all_pendants.(~data).collect { |x| x.keys }.reduce { |a, b| union(a, b) } // ply, attach, children, colours, knots, id

~range_of.(\attach);
~range_of.(\knot_position);


// some statistics
~properties = ~data.all_entries.collect { |x| x.keys }.inject(Set[], { |a, x| a.addAll(x) });
~properties.do { |p| try { [p, ~data.all_entries.minItem { |x| x[p] ? inf }[p], ~data.all_entries.maxItem { |x| x[p] ? 0 }[p]] }.postln}

~data.node_dict['38s1:0'];
~data.node_dict[1];


~data.all_nodes.collect { |x| x[\fillcolor] ? Color.black }.as(Set)

Color.fromHexString("#7D512D")

/*
s.options.device = "MOTU UltraLite mk3 Hybrid";
s.reboot;
*/

/*
Association(key, value)

1 -> 2
\primary -> \something
*/



(
~top_links = ~data.all_links.select { |x| x[\value].key == \primary };

~top_pendants = ~top_links.collect { |x|
	~data.node_dict[x[\value].value]
};

)

4
(
SynthDef(\sin, { |out, freq = 440, sustain = 1, pan, amp = 0.1, ply|
	var attack = blend(0, 1, ply) * sustain;
	var release = blend(1, 0, ply) * sustain;
	var env = EnvGen.ar(Env.perc(attack, release, amp * 3), doneAction:2);
	var son = SinOsc.ar(freq);
	Out.ar(out, Pan2.ar(son, pan, env * AmpCompA.kr(freq)));

}).add;

)
(
SynthDef(\sin, { |out, freq = 440, sustain = 1, pan, amp = 0.1|
	var env = LFGauss.ar(sustain, 0.3, loop:0, doneAction:2);
	var son = SinOsc.ar(freq);
	Out.ar(out, Pan2.ar(son, pan, env * (amp * 2 * AmpCompA.kr(freq))));
}).add;

)

~data.all_nodes.collect { |x| x[\value] }
// inka telefax
(
Tdef(\x, {
	~top_pendants.do { |x|
		var color = x[\fillcolor], note;
		x[\value].postln;
		if(color != nil and: color != \yellow) {
			note =  [color.red, color.green, color.blue] * 32;
			(note:note, sustain: 0.1, instrument: \sin).play;
		};
		0.1.wait;
	}
}).play
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


s.latency = 0.4;


(
Tdef(\x, {
	var pani = ('R':-1, 'V':1, 'U':0);
	var plyi = ('S': 0, 'Z': 1, 'U': 0.5);
	~data.all_pendants.do { |x|
		var color = x[\fillcolor], note, pan, len, ply;
		var dur;
		//x[\value].postln;
		dur = 1/2 ** (~find_level.(x, ~data) - 1);
		dur = (dur / 10);
		dur.wait;
		if(color != nil) {
			pan = pani[x[\pendant_attach]];
			ply = plyi[x[\pendant_ply]];
			len = x[\pendant_length] ? 25 / 25;
			note =  [color.red, color.green, color.blue] * 36 + 12;
			(
				note:note,
				dur: dur,
				instrument: \sin,
				amp: 0.1/3,
				pan: pan,
				legato:len * 1.5,
				ply: ply
			).play;
		};

	}
}).play
)

s.recChannels = 2;
s.options.numOutputBusChannels = 2;
s.reboot;
s.record;
s.stopRecording;

[1, 2, 3, 4, 2, 3].collect { |x| x ** 2 }
[1, 2, 3, 4, 2, 3].select { |x|  x % 2 == 0  }

z = ~data.all_nodes[0];
z[\fillcolor]

~data.all_nodes.collect { |x| x[\qtype] }.as(Set)
~data.all_nodes.collect { |x| x[\fillcolor] }.as(Set)

// knots
~data.all_knots
~data.all_knots.collect { |x| x[\knot_spin] ? -1 }.as(Set)
~data.all_knots.collect { |x| x[\knot_position] ? -1 }.as(Set)
~data.all_knots.collect { |x| x[\knot_value] ? -1 }.as(Set)


(
Tdef(\x, {
	~data.all_knots.do { |x|
		var color = x[\fillcolor], note, pan;
		//x[\value].postln;
		note = x[\knot_value];
		pan = x[\knot_spin];
		if(color != nil) {
			(note:note, out: x[\knot_position] - 6, sustain: 0.01, instrument: \sin, sustain: 0.4).play;
		};
		0.1.wait;
	}
}).play
)

~data.all_pendants[0];

(
~getKnots = { |node|
	var id = node[\value].asString ++ ":";
	~data.all_nodes.select { |x| x[\value].asString.beginsWith(id) };
}.flop;
)

~getKnots.(~data.all_pendants[0]);
a = ~getKnots.(~data.all_pendants).collect { |x| x.collect { |y| y[\knot_spin] } }
b = a.as(Set)

(
Tdef(\x, {
	var dict = (
		'S': (note: 0, sustain: 0.01, instrument: \sin, sustain: 0.04),
		'Z': (note: 6, sustain: 0.01, instrument: \sin, sustain: 0.04),
		'U': (note: 23, sustain: 0.01, instrument: \sin, sustain: 0.04)
	);
	~getKnots.(~data.all_pendants).do { |knots|
		knots.collect { |x| x[\knot_spin] }.postln;
		knots.do { |x|
			var event, spin;
			spin = x[\knot_spin];
			event = dict[spin];
			event = event ?? { (note: -5, sustain: 0.01, instrument: \sin, sustain: 0.04) };
			event.play;
			0.1.wait;
			//event[\dur].wait;
		};
		0.2.wait;
	};

}).play
)


