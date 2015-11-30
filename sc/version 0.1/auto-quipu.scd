

{ |path|
	~load_file.(path, {

		// different schema of calculating durations (the first one sounds actually much nicer ...)

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
				dur = durations[i] ? 1 * 0.1;

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


	});

};