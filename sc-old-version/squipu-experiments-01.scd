/*
~allNodes
~allLinks
~nodeDict
*/

// load library
loadRelative("scquipu-lib.scd");


// load data set
//~loadFile.("/data/more/dot/UR004.xls.dot");
//~loadFile.("../data/more/dot/HP019.xls.dot");
~loadFile.("../data/xl/UR019.xls.dot");

//~loadFile.("/Users/wanninger/Dropbox/IMM/Musikinformatik/Projekte/Quipu/data/more/dot/UR004.xls.dot");

// astronomical quipu
~loadFile.("../data/xl/UR006.xls.dot");
~loadFile.("../data/xl/UR009.xls.dot");
~loadFile.("../data/xl/UR067.xls.dot");
~loadFile.("../data/xl/UR066.xls.dot");

~loadFile.("../data/xl/UR068.xls.dot");

// many nodes here
~nodeDict.keys.size

// find some random ones
10.do { ~nodeDict.choose.postcs; "---------".postln };

~allNodes[0].cs
~allNodes[1].cs
~allLinks[1]

(
~rangeOf = { |parameter|
	parameter.asArray.collect {|p|
		try { [~everything.minItem { |x| x[p] ? inf }[p], ~everything.maxItem { |x| x[p] ? -inf }[p]] }
	}.unbubble
};
~allValuesOf = { |parameter|
	parameter.asArray.collect {|p|
		~everything.collect { |x| x[p] }.reject { |x| x.isNil }.as(Set).as(Array).sort
	}.unbubble
};
)


~rangeOf.(\knot_position);
~rangeOf.(\knot_position);
~allValuesOf.(\knot_position);


// some statistics
~properties = ~everything.collect { |x| x.keys }.inject(Set[], { |a, x| a.addAll(x) });
~properties.do { |p| try { [p, ~everything.minItem { |x| x[p] ? inf }[p], ~everything.maxItem { |x| x[p] ? 0 }[p]] }.postln}

~nodeDict['38s1:0'];
~nodeDict[1];


~allNodes.collect { |x| x[\fillcolor] ? Color.black }.as(Set)

Color.fromHexString("#7D512D")

s.options.device = "MOTU UltraLite mk3 Hybrid";
s.reboot;

/*
Association(key, value)

1 -> 2
\primary -> \something
*/


(
~topLevelLinks = ~allLinks.select { |x| x[\value].key == \primary };
~topLevelOnes = ~topLevelLinks.collect { |x|
	~nodeDict[x[\value].value]
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

~allNodes.collect { |x| x[\value] }
// inka telefax
(
Tdef(\x, {
	~topLevelOnes.do { |x|
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
	~topLevelOnes.do { |x|
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

//~allPendants = ~allNodes.collect {|x| x };

~allPendants = ~allNodes.select {|x| x[\qtype] == \pendant_node };

(
~findParentPendant = { |node|
	var parentLink;
	parentLink = ~allLinks.select {|x| x[\value].value == node[\value]}[0];
	parentLink !? {
	~nodeDict[parentLink[\value].key]
	}
};
~findLevel = { |node|
	var parent = node, level = 0;
	while {
		parent.notNil
	} {
		parent = ~findParentPendant.(parent);
		level = level + 1
	};
	level
};
)

~findParentPendant.(~allNodes[4]); // find parent link
~findLevel.(~allNodes[4]); // find parent link
~findLevel.(~allNodes[3]); // find parent link
~findLevel.(~allNodes[0]); // find parent link
~findLevel.(~allNodes[5]); // find parent link

s.latency = 0.4;

~allPendants.choose
(
~allPendants = ~allNodes.select {|x| x[\qtype] == \pendant_node };
~allLevels = ~allPendants.collect { |x| ~findLevel.(x) };
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

z = ~allNodes[0];
z[\fillcolor]

~allNodes.collect { |x| x[\qtype] }.as(Set)
~allNodes.collect { |x| x[\fillcolor] }.as(Set)

~allKnots = ~allNodes.select {|x| x[\qtype] == \knot_node };
~allKnots.collect { |x| x[\knot_spin] ? -1 }.as(Set)
~allKnots.collect { |x| x[\knot_position] ? -1 }.as(Set)
~allKnots.collect { |x| x[\knot_value] ? -1 }.as(Set)

(
~allKnots = ~allNodes.select {|x| x[\qtype] == \knot_node };
Tdef(\x, {
	~allKnots.do { |x|
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

~allPendants = ~allNodes.select {|x| x[\qtype] == \pendant_node };
~allPendants[0];

(
~getKnots = { |node|
	var id = node[\value].asString ++ ":";
	~allNodes.select { |x| x[\value].asString.beginsWith(id) };
}.flop;
)
~getKnots.(~allPendants[0]).collect { |x| x[\knot_spin] }
a = ~getKnots.(~allPendants).collect { |x| x.collect { |y| y[\knot_spin] } }

b = a.as(Set)

(
Tdef(\x, {
	var dict = (
		'S': (note: 0, sustain: 0.01, instrument: \sin, sustain: 0.04),
		'Z': (note: 6, sustain: 0.01, instrument: \sin, sustain: 0.04),
		'U': (note: 23, sustain: 0.01, instrument: \sin, sustain: 0.04)
	);
	~getKnots.(~allPendants).do { |knots|
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

//////////////////////////////////



~nodeDict[\primary] // nil


~findNode.('67');
~findDown.((value: 'X1' -> '67'));
~findUp.((value: '67' -> 'X1s1'));



// crawl around

~first = ~allLinks.select { |x| x[\value].key == 'primary' };
~first.size; // 407 links

~second = ~first.collect { |x| ~findDown.(x) };
~second.collect { |x| x.size }.as(Set); // only 1

~third = ~second.collect { |x| x.collect { |y| ~findDown.(y) } };
~third.flatten(1).collect { |x| x.collect(_.size).as(Set) }.as(Set); // sizes

~fourth = ~third.deepCollect(3, { |x| ~findDown.(x) });
~fourth.flatten(2).collect { |x| x.collect(_.size).as(Set) }.as(Set); // sizes

~fifth = ~fourth.deepCollect(4, { |x| ~findDown.(x)  });
~fifth.flatten(3).collect { |x| x.collect(_.size).as(Set) }.as(Set); // sizes

~x6 = ~fifth.deepCollect(5, { |x| ~findDown.(x)  });
~x6.flatten(4).collect { |x| x.collect(_.size).as(Set) }.as(Set); // sizes



// find first level

~first = ~allLinks.select { |x| x[\value].key == 'primary' };

// move one down
~findDown.(~first[2]);

// get the tree structure of three of them
~asTree.(~first.keep(3));

~tree = ~asTree.(~first);
~tree.flat.do { |x| if(x[\type] != \qnode) { x.postln } };""; // none, this is good ..
~tree.maxDepth; // interesting: 3


// experimental stuff ...

[(a: 3), (b: 7)].deepDo(inf, { |x| x.postln }); // problem: deepDo treats dictionaries as yet another level
// todo ...
(
~first = ~allLinks.select { |x| x[\value].key == 'primary' };
~sizesOnLevel = { |n|
	var curr = ~first;
	n.do { |i|
		curr = curr.collect { |x| ~findDown.(x) }.flatten(1);
	};
	curr.collect { |x| x.collect(_.size).as(Set) }.as(Set);
};
)

~sizesOnLevel.(4)
