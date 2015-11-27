

////////////////////////////////
/*

these are not yetimplemented for the new lib

*/

~load_file.("../data/more/dot/UR004.xls.dot", ~data = ());


~data.node_dict[\primary] // nil
~data.node_dict['67']

~data.link_dict.keys
~data.link_dict[(value: 'X1' -> '67')]

// need to find the quipu which has them ...

~find_down.((value: 'X1' -> '67'), ~data);
~findUp.((value: '67' -> 'X1s1'), ~data);



// crawl around

~first = ~data.all_links.select { |x| x[\value].key == 'primary' };
~first.size; // 407 links

~second = ~first.collect { |x| ~data.find_down.(x, ~data) };
~second.collect { |x| x.size }.as(Set); // only 1

~third = ~second.collect { |x| x.collect { |y| ~data.find_down.(y, ~data) } };
~third.flatten(1).collect { |x| x.collect(_.size).as(Set) }.as(Set); // sizes

~fourth = ~third.deepCollect(3, { |x| ~data.find_down.(x, ~data) });
~fourth.flatten(2).collect { |x| x.collect(_.size).as(Set) }.as(Set); // sizes

~fifth = ~fourth.deepCollect(4, { |x| ~data.find_down.(x, ~data)  });
~fifth.flatten(3).collect { |x| x.collect(_.size).as(Set) }.as(Set); // sizes

~x6 = ~fifth.deepCollect(5, { |x| ~data.find_down.(x, ~data)  });
~x6.flatten(4).collect { |x| x.collect(_.size).as(Set) }.as(Set); // sizes



// find first level

~first = ~data.all_links.select { |x| x[\value].key == 'primary' };

// move one down
~data.find_down.(~first[2]);

// get the tree structure of three of them
~asTree.(~first.keep(3));

~tree = ~asTree.(~first);
~tree.flat.do { |x| if(x[\type] != \qnode) { x.postln } };""; // none, this is good ..
~tree.maxDepth; // interesting: 3


// experimental stuff ...

[(a: 3), (b: 7)].deepDo(inf, { |x| x.postln }); // problem: deepDo treats dictionaries as yet another level
// todo ...
(
~first = ~data.all_links.select { |x| x[\value].key == 'primary' };
~sizesOnLevel = { |n|
	var curr = ~first;
	n.do { |i|
		curr = curr.collect { |x| ~data.find_down.(x, ~data) }.flatten(1);
	};
	curr.collect { |x| x.collect(_.size).as(Set) }.as(Set);
};
)

~sizesOnLevel.(4)
