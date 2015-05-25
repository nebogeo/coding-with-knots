
// load library
loadRelative("scquipu-lib.scd");

// load data set
~loadFile.("data/UR001.xls.dot");

// many nodes here
~nodeDict.keys.size

// find some random ones
10.do { ~nodeDict.choose.postcs; "---------".postln };


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
