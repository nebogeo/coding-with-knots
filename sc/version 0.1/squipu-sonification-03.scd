/*

we have nodes and links:
~allNodes
~data.all_links


nodes are of two types:
~allPendants
~allKnots

a lookup table for names of nodes:
~data.node_dict

*/



// load the library
(
currentEnvironment = (); // make local
loadRelative("scquipu-lib.scd");
~data = currentEnvironment;
)

// load one of the following data sets:

// quipu data
~load_file.("../data/more/dot/UR004.xls.dot");
~load_file.("../data/more/dot/HP019.xls.dot");
~load_file.("../data/xl/UR019.xls.dot");

// astronomical quipu
~load_file.("../data/xl/UR006.xls.dot");
~load_file.("../data/xl/UR009.xls.dot");

// variants of administrative quipus
~load_file.("../data/xl/UR066.xls.dot");
~load_file.("../data/xl/UR067.xls.dot");
~load_file.("../data/xl/UR068.xls.dot");

~load_file.("../data/xl/UR139.xls.dot");

(
SynthDef(\sin, { |out, freq = 440, sustain = 1, pan, amp = 0.1, ply|
	var attack = ply.linlin(0, 1, 0.001, 1) * sustain;
	var release = ply.linlin(0, 1, 1, 0.01) * sustain;
	var env = EnvGen.ar(Env.perc(attack, release, amp * 3), doneAction:2);
	var son = SinOsc.ar(freq);
	OffsetOut.ar(out, Pan2.ar(son, pan, env * AmpCompA.kr(freq)));
}).add;
)


(
~go_down = { |name, func, depth = 0|
	var step, all = ~data.all_links.select { |x| x[\value].key == name };
	func.value(name, depth);
	step = if(all.size > 1) { 1 } { 0 };
	all.do { |each|
		var name = each[\value].value;
		~go_down.(name, func, depth + step)
	};
};
)


~data.node_dict.keys.do { |x| ~go_down.(x, _.postln) };

~go_down.(\primary, { |x| x.postln })

~data.node_dict.keys.choose;



// this is knot jazz
// where there are no knots, we aint play no knots
// we here the position on the quipu: 1 cm = 100 cents

(
Tdef(\x, {
	~go_down.(\primary, { |name, depth|
		var node, pos, note, dur;
		node = ~data.node_dict[name];
		if(node.notNil) {
			dur = ((2/3 ** depth.postln) * 0.24);
			//dur = 0.1 + 0.01.rand2;
			pos = node[\knot_position];
			if(pos.notNil) {
				note = pos;
				(note:note, sustain: dur, instrument: \sin).play;
			} {
				dur.wait
			}
		}
	})
}).play
)



// quipu calculus: knot value
(
Tdef(\x, {
	~go_down.(\primary, { |name, depth|
		var node, pos, note, dur;
		node = ~data.node_dict[name];
		if(node.notNil) {
			dur = ((0.5 ** depth) * 0.2);
			//dur = 0.1;
			pos = node[\knot_position];
			if(pos.notNil) {
				note =  node[\knot_value] * 6;
				(note:note, sustain: dur, instrument: \sin).play;
			};
			dur.wait;
		}
	})
}).play
)

// play knots on the same pendant in parallel: knot position
(
Tdef(\x, {
	~go_down.(\primary, { |name, depth|
		var node, pos, note, dur;
		node = ~data.node_dict[name];
		if(node.notNil) {
			dur = ((2/3 ** depth) * 0.2);
			//dur = 0.1;
			pos = node[\knot_position];
			//var color = node[\fillcolor];
			if(pos.notNil) {
				note =  pos * 2; // + ([color.red, color.green, color.blue] * 5);
				(note: note, sustain: dur, instrument: \sin).play;
			} {
				dur.wait;
			}
		}
	})
}).play
)


/*
(
~data.all_links.do { |x| x[\knots] = nil };
~data.all_links.do { |x|
	var from = x[\value].key;
	var to = x[\value].value;
	var nodeFrom = ~data.node_dict[from];
	var nodeTo = ~data.node_dict[to];

	if(nodeFrom.notNil and: { nodeTo.notNil }) {
		if(nodeTo[\qtype] == \knot_node) {
			nodeFrom[\knots] = nodeFrom[\knots].add(nodeTo);
			nodeFrom[\knots];
		};
	};
}; ""
)

*/

Server.default.makeGui
~load_file.("../data/xls/UR113.xls.dot");

// quipu soup: knot value and pendant colour
(

Tdef(\x, {
	var pani = ('R':-1, 'V':1, 'U':0);
	var plyi = ('S': 0, 'Z': 1, 'U': 0.5);
	~go_down.(\primary, { |name, depth|
		var node, pos, note, dur, color, attach, pan, len, ply;
		node = ~data.node_dict[name];

		if(node.notNil) {
			dur = ((0.5 ** depth) * 0.2);
			//dur = 0.1;

			color = node[\fillcolor];
			attach = node[\pendant_attach];
			if(attach.notNil) {
				// we are a pendant
				pan = pani[node[\pendant_attach]];
				ply = plyi[node[\pendant_ply]];
				len = node[\pendant_length] ? 25 / 25;
				note =  [color.red, color.green, color.blue] * 12 + 12;
				(
					note: note,
					dur: len * 0.2, // play longer than knots
					instrument: \sin,
					amp: 0.1/3,
					pan: pan,
					legato:len * 1.5,
					ply: ply
				).play;
			} {
				// we are a knot
				pos = node[\knot_position];
				if(pos.notNil) {
					note =  node[\knot_value] * 6;
					(note:note, sustain: dur, instrument: \sin).play;
				};
			};
			dur.wait;
		}
	})
}).play
)
