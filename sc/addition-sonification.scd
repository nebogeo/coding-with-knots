




a[0].asDigits.collect(_.class)

(
f = { |num|
	num.postln;
	num.asDigits.do { |each|
			(note:each * 2, sustain: 0.1, instrument: \sin).play;
			0.1.wait
		};
};
Tdef(\x, {
	var sum = 0;
	a = { 100000.rand } ! rrand(3, 7);
	a.do { |x|
		f.(x);
		1.0.wait;
		sum = sum + x;
		f.(sum);
		0.4.wait;
	};
}).play
)

(
var primes = (0..6000).nthPrime;
f = { |num|
	num.postln;
	num.factors.postln.do { |each|
		var note = (primes.indexOf(each) ? 1).explin(1, 6000, 0, 74);
		(note: note, sustain: 0.1, instrument: \sin).play;
		0.01.wait
	};
};
Tdef(\x, {
	var sum = 0;
	a = { 100000.rand } ! rrand(3, 7);
	a.do { |x|
		f.(x);
		1.0.wait;
		sum = sum + x;
		f.(sum);
		0.4.wait;
	};
}).play
)