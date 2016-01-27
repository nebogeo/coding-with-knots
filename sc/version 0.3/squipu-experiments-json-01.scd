/*

Sonifications using the json format

*/



// load one of the following data sets:
~data = ~getQuipuData.("../../json/UR004.json".resolveRelative);
~data = ~getQuipuData.("../../json/HP019.json".resolveRelative);
~data = ~getQuipuData.("../../json/UR019.json".resolveRelative);


// boring quipu
~data = ~getQuipuData.("../../json/UR046.json".resolveRelative);


// astronomical quipu
~data = ~getQuipuData.("../../json/UR006.json".resolveRelative);
~data = ~getQuipuData.("../../json/UR009.json".resolveRelative);

// variants of administrative quipus
~data = ~getQuipuData.("../../json/UR066.json".resolveRelative);
~data = ~getQuipuData.("../../json/UR067.json".resolveRelative);
~data = ~getQuipuData.("../../json/UR068.json".resolveRelative);



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
SynthDef(\gabor, { |out, freq = 440, sustain = 1, pan, amp = 0.1|
	var env = LFGauss.ar(sustain, 0.3, loop:0, doneAction:2);
	var son = SinOsc.ar(freq);
	Out.ar(out, Pan2.ar(son, pan, env * (amp * 2 * AmpCompA.kr(freq))));
}).add;
)

(
~traverse = { |dict, func, level = 0, index = 0|
	dict[\children].do { |each, i| ~traverse.(each, func, level + 1, i) };
	func.value(dict, level, index);
}
);

~traverse.(~data, { |x| x[\colours].postln }); // test

// inka telefax: traversal
(
Tdef(\x, {
	~traverse.(~data, { |x|
		var colours = x[\colours], note;
		colours.do { |colour|
			note =  [colour.red, colour.green, colour.blue] * 32;
			(note:note, sustain: 0.1, instrument: \sin).play;
		};
		0.1.wait;
	})
}).play
)
