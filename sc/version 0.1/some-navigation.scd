


~entropy.([(a: 8, u: 9), (a: 8)])
~entropy.([(a: 8), (a: 8)])

~entropy.([1, 1])
~entropy.([Color(1, 1, 1), Color(1, 1, 1)])
~entropy.([Color(1, 1, 1), Color(1, 0.3, 1)])
~entropy.([Color(1, 1, 1), Color(1, 1.0, 1)])

1 == 1.0

f.([(a: 8, u: 9), (a: 8)])
f.([(a: 8), (a: 8)])

// Association
a = (8 -> 9);
a.key;
a.value;



~all_nodes[0]

~all_pendants = ~all_nodes.select { |x| x[\qtype] == \pendant_node };
~all_pendants_ids = ~all_pendants.collect { |x| x[\value] };

~all_links.select { |x| ~all_pendants_ids.includes(x[\value].key)  }.select { |x| x[\qtype] == \knot_node };


~all_knots = ~all_nodes.select { |x| x[\qtype] == \knot_node };
~all_knots.collect { |x| ~find_up.(x) };

~all_knots.collect { |x| ~find_up.(x) };


(
f = { |node|
	var links;
	var key = node[\value];
	key
	/*
	if(node[\type] == \qnode) {
		links = ~all_links.select { |x|
			x[\value].value == key;
		};
		links.collect { |x| ~node_dict[x] };
	} {
		[~node_dict[node[\value].key]];
	}
	*/
};
);


(
f = { |node|
	var links;
	var key = node[\value];

	if(node[\type] == \qnode) {

		/*
		links = ~all_links.select { |x|
			x[\value].value == key;
		};
		links.collect { |x| ~node_dict[x] };
		*/
	} {
		[~node_dict[node[\value].key]];
	}

};
);

~all_links.collect { |x| f.(x) };
~all_nodes.collect { |x| f.(x) };

(
f = { |node|
	var uplinks;
	var key = node[\value];

	if(node[\type] == \qlink) {
		uplinks = [node]
	} {
		uplinks = ~all_links.select { |x|
			x[\value].value == key;
		};
	};
	uplinks.collect { |x| ~node_dict[x[\value].key] };
};
);

~all_links.collect { |x| f.(x) };
~all_nodes.collect { |x| f.(x) };




~allKnot_ids = ~allKnots.collect { |x| x[\value] };

~links_attached_to_knots = ~allKnot_ids.collect { |id|
	(id -> ~all_links.select { |x| x[\value].value == id })
};

~links_attached_to_knots[0]