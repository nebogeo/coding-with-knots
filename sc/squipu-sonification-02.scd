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
//~loadFile.("/data/more/dot/UR004.xls.dot");
//~loadFile.("../data/more/dot/HP019.xls.dot");
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
	var attack = blend(0.001, 1, ply) * sustain;
	var release = blend(1, 0.01, ply) * sustain;
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


// inka telefax
(
Tdef(\x, {
	~topLevelPendants.do { |x|
		var color = x[\fillcolor], note;
		x[\value].postln;
		if(color != nil) {
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
	~topLevelPendants.do { |x|
		var color = x[\fillcolor], note;
		x[\value].postln;
		if(color != nil) {
			note =  [color.red, color.green, color.blue] * 32;
			(note:note, sustain: 0.6, instrument: \sin).play;
		};
		0.1.wait;
	}
}).play
)



~findParentPendant.(~allNodes[4]); // find parent link
~findLevel.(~allNodes[4]); // find parent link
~findLevel.(~allNodes[3]); // find parent link
~findLevel.(~allNodes[0]); // find parent link
~findLevel.(~allNodes[5]); // find parent link

(
~allPendants = ~allNodes.select {|x| x[\qtype] == \pendant_node };
~levels = ~allPendants.collect { |x| ~findLevel.(x) };
)

(
Tdef(\x, {
	var pani = ('R':-1, 'V':1, 'U':0);
	var plyi = ('S': 0, 'Z': 1, 'U': 0.5);
	~allPendants.do { |x|
		var color = x[\fillcolor], note, pan, len, ply;
		var dur;
		//x[\value].postln;
		dur = 1/2 ** (~findLevel.(x) - 1);
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
				amp: 0.1,
				pan: pan,
				legato:len * 1.5,
				ply: ply
			).play;
		};

	}
}).play
)

// different schema of calculating durations (the first one sounds actually much nicer ...)
(
var accelbase = 1/2; // how much to speed up for each subsidiary level
var accelexp = 0.5; // how much to broaden the gap for fitting in subsidiaries
var gap = 0.5; // separates subsidiaries from following pendant. 1 = one full time step
var subsidiaries = ~levels.separate { |a, b| b == 1 };
~durations = subsidiaries.collect { |d|
	d = accelbase ** (d - 1);
	d[d.lastIndex] = d[d.lastIndex] + gap;
	d/(d.sum ** accelexp)
}.flat;

Tdef(\x, {


	var pani = ('R':-1, 'V':1, 'U':0);
	var plyi = ('S': 0, 'Z': 1, 'U': 0.5);
	~allPendants.do { |x, i|
		var color = x[\fillcolor], note, pan, len, ply;
		var dur;
		//x[\value].postln;
		dur = ~durations[i] * 0.1;

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
		dur.wait;

	}
}).play
)

/////////////////////////// recording //////////////

s.recChannels = 2;
s.options.numOutputBusChannels = 2;
s.reboot;

s.record; // start
s.stopRecording; // stop
