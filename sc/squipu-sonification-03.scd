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
~topLevelLinks = ~allLinks.select { |x| x[\value].key == \primary };

~topLevelPendants = ~topLevelLinks.collect { |x|
	~nodeDict[x[\value].value]
};

)

~allKnots = ~allNodes.select {|x| x[\qtype] == \knot_node };
~allPendants = ~allNodes.select {|x| x[\qtype] == \pendant_node };

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

(
~goDown = { |name, func, depth = 0|
	var all = ~allLinks.select { |x| x[\value].key == name };
	func.value(name, depth);
	all.do { |each|
		var name = each[\value].value;
		~goDown.(name, func, depth + 1)
	};
};
)

~nodeDict.keys.do { |x| ~goDown.(x, _.postln) };

~goDown.(\primary, { |x| x.postln })

~nodeDict.keys.choose;

// this is knot jazz
// where there are no knots, we aint play no knots
(
Tdef(\x, {
	~goDown.(\primary, { |name, depth|
		var node, pos, note, dur;
		node = ~nodeDict[name];
		if(node.notNil) {
			//dur = ((0.5 ** depth) * 0.5);
			dur = 0.1;
			pos = node[\knot_position];
			//var color = node[\fillcolor];
			if(pos.notNil) {
				note =  pos; // + ([color.red, color.green, color.blue] * 5);
				(note:note, sustain: dur, instrument: \sin).play;
			};
			dur.wait;
		}
	})
}).play
)

// quipu calculus
(
Tdef(\x, {
	~goDown.(\primary, { |name, depth|
		var node, pos, note, dur;
		node = ~nodeDict[name];
		if(node.notNil) {
			//dur = ((0.5 ** depth) * 0.5);
			dur = 0.1;
			pos = node[\knot_position];
			//var color = node[\fillcolor];
			if(pos.notNil) {
				note =  node[\knot_value] * 6;
				(note:note, sustain: dur, instrument: \sin).play;
			};
			dur.wait;
		}
	})
}).play
)

(
Tdef(\x, {
	~goDown.(\primary, { |name, depth|
		var node, pos, note, dur;
		node = ~nodeDict[name];
		if(node.notNil) {
			//dur = ((0.5 ** depth) * 0.5);
			dur = 0.1;
			pos = node[\knot_position];
			//var color = node[\fillcolor];
			if(pos.notNil) {
				note =  pos; // + ([color.red, color.green, color.blue] * 5);
				(note:note, sustain: dur, instrument: \sin).play;
				//(dur / (depth + 1)).wait;
			} {
				dur.wait;
			}
		}
	})
}).play
)


~allNodes.select { |x| x[\knots].notNil }
~allNodes.select { |x| x[\knots].notNil }.collect { |x| x[\knots].collect { |y| y[\knot_position] } }.flat.as(Set).as(Array).sort;


~allKnots[0].postln; "";

~allKnots.collect { |x| x[\value] }

// this is knot jazz
(
Tdef(\x, {
	~allNodes.do { |x|
		var color = x[\fillcolor], note;
		if(x[\knots].notNil) {
			note = x[\knots].collect { |y| y[\knot_position] }.postln;
			(note:note, sustain: 0.1, instrument: \sin).play;
			0.01.wait;
		};
		0.1.wait;
	}
}).play
)



