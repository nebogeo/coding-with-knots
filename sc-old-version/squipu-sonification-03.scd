/*

we have nodes and links:
~allNodes
~allLinks


nodes are of two types:
~allPendants
~allKnots

a lookup table for names of nodes:
~nodeDict

*/

// load library
loadRelative("scquipu-lib.scd");

// load data set
~loadFile.("../data/more/dot/UR004.xls.dot");
~loadFile.("../data/more/dot/HP019.xls.dot");
~loadFile.("../data/xl/UR019.xls.dot");

// astronomical quipu
~loadFile.("../data/xl/UR006.xls.dot");
~loadFile.("../data/xl/UR009.xls.dot");

// variants of administrative quipus
~loadFile.("../data/xl/UR066.xls.dot");
~loadFile.("../data/xl/UR067.xls.dot");
~loadFile.("../data/xl/UR068.xls.dot");


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
~goDown = { |name, func, depth = 0|
	var step, all = ~allLinks.select { |x| x[\value].key == name };
	func.value(name, depth);
	step = if(all.size > 1) { 1 } { 0 };
	all.do { |each|
		var name = each[\value].value;
		~goDown.(name, func, depth + step)
	};
};
)


~nodeDict.keys.do { |x| ~goDown.(x, _.postln) };

~goDown.(\primary, { |x| x.postln })

~nodeDict.keys.choose;



// this is knot jazz
// where there are no knots, we aint play no knots
// we here the position on the quipu: 1 cm = 100 cents

(
Tdef(\x, {
	~goDown.(\primary, { |name, depth|
		var node, pos, note, dur;
		node = ~nodeDict[name];
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
	~goDown.(\primary, { |name, depth|
		var node, pos, note, dur;
		node = ~nodeDict[name];
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
	~goDown.(\primary, { |name, depth|
		var node, pos, note, dur;
		node = ~nodeDict[name];
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
~allLinks.do { |x| x[\knots] = nil };
~allLinks.do { |x|
	var from = x[\value].key;
	var to = x[\value].value;
	var nodeFrom = ~nodeDict[from];
	var nodeTo = ~nodeDict[to];

	if(nodeFrom.notNil and: { nodeTo.notNil }) {
		if(nodeTo[\qtype] == \knot_node) {
			nodeFrom[\knots] = nodeFrom[\knots].add(nodeTo);
			nodeFrom[\knots];
		};
	};
}; ""
)

*/