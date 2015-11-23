/*

we have nodes and links:
~data.all_nodes
~all_links


nodes are of two types:
~data.all_pendants
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
~top_links = ~data.all_links.select { |x| x[\value].key == \primary };

~top_pendants = ~top_links.collect { |x|
	~data.node_dict[x[\value].value]
};

)


(note:[0, 5, 6], sustain: 0.8, instrument: \sin).play;
(note:[0, 5, 6] + 12, sustain: [0.3, 1.9, 0.8], instrument: \sin).play;
(note:[0, 5, 6, 9, 11, 22] + 12, sustain: [0.3, 1.9], instrument: \sin).play;

// inka telefax
(
Tdef(\x, {
	~top_pendants.do { |x|
		var color = x[\fillcolor], note;
		x[\value].postln;
		if(color != nil) {
			note =  [color.red, color.green, color.blue] * 32 + 24;
			(note:note, sustain: 0.08, instrument: \sin).play;
		};
		0.05.wait;
	}
}).play
)

// inka telefax
(
Tdef(\x, {
	~top_pendants.do { |x|
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



~find_parentPendant.(~data.all_nodes[4], ~data); // find parent link
~find_level.(~data.all_nodes[4], ~data); // find parent link
~find_level.(~data.all_nodes[3], ~data); // find parent link
~find_level.(~data.all_nodes[0], ~data); // find parent link
~find_level.(~data.all_nodes[5], ~data); // find parent link


~levels = ~data.all_pendants.collect { |x| ~data.find_level.(x, ~data) };


// check some colours
~data.all_entries.select { |x| x[\fillcolor].isArray }
~data.all_entries.select { |x| x[\fillcolor] == Color.black }

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
				dur: dur * 0.9,
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
var subsidiaries, levels, durations;

levels = ~data.all_pendants.collect { |x| ~find_level.(x, ~data) };
subsidiaries = levels.separate { |a, b| b == 1 };

durations = subsidiaries.collect { |d|
	d = accelbase ** (d - 1);
	d[d.lastIndex] = d[d.lastIndex] + gap;
	d/(d.sum ** accelexp)
}.flat;

Tdef(\x, {


	var pani = ('R':-1, 'V':1, 'U':0);
	var plyi = ('S': 0, 'Z': 1, 'U': 0.5);
	~data.all_pendants.do { |x, i|
		var color = x[\fillcolor], note, pan, len, ply;
		var dur;
		//x[\value].postln;
		dur = durations[i] * 0.1;

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
