/*
 bb: c, b: cc
Rules:
   S, Ac, A
   Ac, A, C
   A, a, 0
   B, b, 0
   C, c, 0
   Bc, B, C
 */
/*
[S]          0, 0
[ Ac A ]     1, 0  [ Ac->1 A ] 
[ A C A]     6, 2  [ Ac->2 A C ]
[ A C Bc C ] 4, 3
[ A C Bc c ] 5, 2
[ A C B C c ]4, 3
[ a C B C c ]3, 2
[ a C b C c ]2, 0
[ a C b c c ]4, 1
[ a c b c c ]
 */
use dep::std;

global N = 4;
global K = 0;//;
global Log_Rules = 3;

global S = 1;
global Ac = 2;
global A = 3;
global C = 4;
global a = 5;
global c = 6;

global terminals = [
	a, // 0 
	c // 1
];

global non_terminals = [
	S, // 0
	Ac, // 2
	A, // 3
	C, // 4
];

global rules = [
    (S, Ac, Ac),  //0 
    (Ac, Ac, Ac), //1
    (Ac, A, C),   //2
    (A, a, 0),   //3
    (C, c, 0),   //4
    (S, A, C),  //5
];

struct Node {
    next: Field,
    val: Field
}

fn node_equals(node1: Node, node2: Node) -> bool {
    let bool_1 = (node1.next == node2.next);
    let bool_2 = (node1.val == node2.val);
    bool_1 * bool_2
}

struct App {
	rule: Field,
	position: Field
}

unconstrained
fn find_loc(list: [Node; N], loc: Field) -> Field {
    let mut physical_loc: Field = 0;
    let mut req_node = Node { next: -1, val: 0 };
    let mut curr_node = list[0];
    let mut traversed = 0;
    for _ in 0..N {
        if traversed == loc {
            req_node = curr_node;
        } else {
            curr_node = list[curr_node.next];
        }
        traversed += 1;
    }
    let mut counter: Field = 0;
    for i in 0..N {
        if node_equals(list[i], req_node) {
            physical_loc = counter;
        }
        counter = counter + 1;
    }
    physical_loc
}

struct Edge {
	parent: Field,
	child: Field
}

struct Rule {
	left_child: Field,
	right_child: Field,
}





impl Rule {
    fn new(left_child: Field, right_child: Field) -> Self {
        Rule { left_child, right_child }
    }
}

// Used to represent a set of labels
struct Rule2 {
	left_child: Field,
	right_child: Field,
}

impl Rule2 {
    fn new(left_child: Field, right_child: Field) -> Self {
        Rule2 { left_child, right_child }
    }
}

impl Edge {
    fn new(parent: Field, child: Field) -> Self {
        Edge { parent, child }
    }
}

/** 
3*N - 2 edges, of which N should be in-edges to leaves and 2*N-2 are in-edges to non-terminals
which means that the total number of productions is (2*N - 2)/ 2 + N = 2*N - 1
**/

fn checkMemNaive(
    string: [Field; N],
    labels: [Field; 3*N - 1],
    edges: [Edge; 3*N - 2],
    mem_proofs_prod: [Field; 2*N - 1]
) -> bool {
    let mut output = true;
    let mut productions = [Rule::new(-1, -1); 3 * N - 1];
    for i in 0..(3 * N - 2) {
        let parent = edges[i].parent;
        let child = edges[i].child;
        if productions[parent].left_child == -1 {
            productions[parent].left_child = child;
        } else if productions[parent].right_child == -1 {
            productions[parent].right_child = child;
        } else {
            // This is the case where some node has more than two edges outgoing
            output = false;
        }
        let child_value_check = child == ((i + 1) as Field);
        // This should check both the range of parent and the semantics.
        let parent_value_check = parent.lt(child);
        output = output * parent_value_check * child_value_check;
    }

    let mut leaf_checked = 0;
    let mut rules_checked = 0;
    for i in 0..(3 * N - 1) {
		let node = labels[i];
        if productions[i].left_child == -1 {
            // Case where we're checking the leaf
            output = output * (string[leaf_checked] == node);
            leaf_checked = leaf_checked + 1;
        } else {
            let nt = labels[i];
            let left_child = labels[productions[i].left_child];
            // Handle the nt --> ntL ntR rule	
            let mut right_child = labels[productions[i].right_child];
            if productions[i].right_child == -1 {
                // Handle the nt --> terminal rule
                right_child = 0;
            }
            let check = (nt, left_child, right_child) == rules[mem_proofs_prod[rules_checked]];
            output = output * check;
            rules_checked = rules_checked + 1;
        }
    }
    let leaves_check = (leaf_checked == (N as Field));
    output = output * leaves_check;
    output
}

// Same as checkMemNaive but only stores the labels of rules, not positions.
fn checkMemNaive2(
    string: [Field; N],
    labels: [Field; 3*N - 1],
    edges: [Edge; 3*N - 2],
    mem_proofs_prod: [Field; 2*N - 1]
) -> bool {
    let mut output = true;
    let mut productions = [Rule2::new(S, 0); 3 * N - 1];
    for i in 0..(3 * N - 2) {
        let parent = edges[i].parent;
		let child_id = edges[i].child;
        let child = labels[edges[i].child];
        if productions[parent].left_child == S {
            productions[parent].left_child = child;
        } else if productions[parent].right_child == 0 {
            productions[parent].right_child = child;
        } else {
            // This is the case where some node has more than two edges outgoing
            output = false;
        }
        let child_value_check = child_id == ((i + 1) as Field);
        // This should check both the range of parent and the semantics.
        let parent_value_check = parent.lt(child_id);
        output = output * parent_value_check * child_value_check;
    }

    let mut leaf_checked = 0;
    let mut rules_checked = 0;
    for i in 0..(3 * N - 1) {
		let node = labels[i];
        if productions[i].left_child == S {
            // Case where we're checking the leaf
            output = output * (string[leaf_checked] == node);
            leaf_checked = leaf_checked + 1;
        } else {
            let left_child = productions[i].left_child;
            // Handle the nt --> ntL ntR rule	
            let right_child = productions[i].right_child;
            // if productions[i].right_child == S {
            //     // Handle the nt --> terminal rule
            //     right_child = 0;
            // }
            let check = (node, left_child, right_child) == rules[mem_proofs_prod[rules_checked]];
            output = output * check;
            rules_checked = rules_checked + 1;
        }
    }
    let leaves_check = (leaf_checked == (N as Field));
    output = output * leaves_check;
    output
}

struct MerkleProofProductions {
	index: Field,
	hashpath: [Field; Log_Rules]
}

// Same as checkMemNaive but only stores the labels of rules, not positions.
fn parseTreeChecker(
    string: [Field; N],
    labels: [Field; 3*N - 1],
    edges: [Edge; 3*N - 2],
    mem_proofs_prod: [MerkleProofProductions; 2*N - 1],
	rules_com: Field,
) -> bool {
    let mut output = true;
    let mut productions = [Rule2::new(S, 0); 3 * N - 1];
    for i in 0..(3 * N - 2) {
        let parent = edges[i].parent;
		let child_id = edges[i].child;
        let child = labels[edges[i].child];
        if productions[parent].left_child == S {
            productions[parent].left_child = child;
        } else if productions[parent].right_child == 0 {
            productions[parent].right_child = child;
        } else {
            // This is the case where some node has more than two edges outgoing
            output = false;
        }
        let child_value_check = child_id == ((i + 1) as Field);
        // This should check both the range of parent and the semantics.
        let parent_value_check = parent.lt(child_id);
        output = output * parent_value_check * child_value_check;
    }
	
    let mut leaf_checked = 0;
    let mut rules_checked = 0;
	/*********
	let mut leaves = [a as Field; N];
	let mut prods = [0 as Field; 2*N - 1];

    for i in 0..(3 * N - 1) {
		let node = labels[i];
        if productions[i].left_child == S {
            // Case where we're checking the leaf
            leaves[leaf_checked] = node;
            leaf_checked = leaf_checked + 1;
        } else {
            let left_child = productions[i].left_child;
            // Handle the nt --> ntL ntR rule	
            let right_child = productions[i].right_child;
            // if productions[i].right_child == S {
            //     // Handle the nt --> terminal rule
            //     right_child = 0;
            // }
			let rule = [node as Field, left_child as Field, right_child as Field];

			let rule_hash = std::hash::hash_to_field(rule.as_slice());
			prods[rules_checked] = rule_hash;
            rules_checked = rules_checked + 1;
        }
    }
	for i in 0..N {
		output = output * (leaves[i] == string[i]);
	}
	for i in 0..(2*N - 1) {
		let rule_hash = prods[i];
		let index = mem_proofs_prod[i].index;
		let path = mem_proofs_prod[i].hashpath;
		let merkle_root = std::merkle::compute_merkle_root(rule_hash, index, path);
		let check = merkle_root == rules_com;
		output = output * check;
	}
	**********/
	for i in 0..(3 * N - 1) {
		let node = labels[i];
        if productions[i].left_child == S {
            // Case where we're checking the leaf
            output = output * (string[leaf_checked] == node);
            leaf_checked = leaf_checked + 1;
        } else {
            let left_child = productions[i].left_child;
            // Handle the nt --> ntL ntR rule	
            let right_child = productions[i].right_child;
            // if productions[i].right_child == S {
            //     // Handle the nt --> terminal rule
            //     right_child = 0;
            // }
			let index = mem_proofs_prod[rules_checked].index;
			let path = mem_proofs_prod[rules_checked].hashpath;
            let rule = [node as Field, left_child as Field, right_child as Field];
			let rule_hash = std::hash::hash_to_field(rule.as_slice());
			let merkle_root = std::merkle::compute_merkle_root(rule_hash, index, path);
			let check = merkle_root == rules_com;
			output = output * check;
            rules_checked = rules_checked + 1;
        }
    }
    let leaves_check = (leaf_checked == (N as Field));
    output = output * leaves_check;
    output
}

// struct MerkleProofStr {
// 	index: Field,
// 	hashpath: [Field; Log(N)]
// }

// Same as checkMemNaive but only stores the labels of rules, not positions.
fn parseTreeCheckerComStr(
    string: [Field; N],
    labels: [Field; 3*N - 1],
    edges: [Edge; 3*N - 2],
    mem_proofs_prod: [MerkleProofProductions; 2*N - 1],
	rules_com: Field,
) -> bool {
    let mut output = true;
    let mut productions = [Rule2::new(S, 0); 3 * N - 1];
    for i in 0..(3 * N - 2) {
        let parent = edges[i].parent;
		let child_id = edges[i].child;
        let child = labels[edges[i].child];
        if productions[parent].left_child == S {
            productions[parent].left_child = child;
        } else if productions[parent].right_child == 0 {
            productions[parent].right_child = child;
        } else {
            // This is the case where some node has more than two edges outgoing
            output = false;
        }
        let child_value_check = child_id == ((i + 1) as Field);
        // This should check both the range of parent and the semantics.
        let parent_value_check = parent.lt(child_id);
        output = output * parent_value_check * child_value_check;
    }
	
    let mut leaf_checked = 0;
    let mut rules_checked = 0;
	
	for i in 0..(3 * N - 1) {
		let node = labels[i];
        if productions[i].left_child == S {
            // Case where we're checking the leaf
            output = output * (string[leaf_checked] == node);
            leaf_checked = leaf_checked + 1;
        } else {
            let left_child = productions[i].left_child;
            // Handle the nt --> ntL ntR rule	
            let right_child = productions[i].right_child;
            // if productions[i].right_child == S {
            //     // Handle the nt --> terminal rule
            //     right_child = 0;
            // }
			let index = mem_proofs_prod[rules_checked].index;
			let path = mem_proofs_prod[rules_checked].hashpath;
            let rule = [node as Field, left_child as Field, right_child as Field];
			let rule_hash = std::hash::hash_to_field(rule.as_slice());
			let merkle_root = std::merkle::compute_merkle_root(rule_hash, index, path);
			let check = merkle_root == rules_com;
			output = output * check;
            rules_checked = rules_checked + 1;
        }
    }
    let leaves_check = (leaf_checked == (N as Field));
    output = output * leaves_check;
    output
}

fn naive_impl(string: [Field; N], apps: [App; 2*N-1]) {
    // Start with Start symbol    
    let mut list = [Node { next: 0, val: 0 }; N];

    list[0].val = S;
    let mut listHead = 0; // Start of list
    let mut listNext = 1; // next unallocated node

    // Apply rules
    for rl in apps {
        let rule = rl.rule;
        let physical_loc = rl.position;
        let (nt, ntL, ntR) = rules[rule];
        // check rule applies to correct non terminal
        assert(list[physical_loc].val == nt);

        if (ntR == 0) { // NT to T
            // Replace in place
            list[physical_loc].val = ntL;
        } else { // NT to (NT,NT)

            // Add a new node to the end
            list[listNext].val = ntR;
            list[physical_loc].val = ntL;

            // New node points to the next.
            // Modify current node to point to new one
            list[listNext].next = list[physical_loc].next;
            list[physical_loc].next = listNext;
            listNext += 1;
        }
    }

    // Check final string matches
    let mut cur = listHead;
    for i in 0..N {
        assert(string[i] == list[cur].val);
        cur = list[cur].next;
    }
    assert(cur == 0);
}

fn check_array_access(locs: [Field; K], arr: [Field; N], vals: [Field; K]) {
	for i in 0..K {
		let loc = locs[i];
		assert(arr[loc] == vals[loc]);
	}
		
}

// fn main(locs: [Field; K], arr: [Field; N], vals: [Field; K]) {
// 	check_array_access(locs, arr, vals);
// }

fn main(
    string: [Field; N],
    labels: [Field; 3*N - 1],
    edges: [Edge; 3*N - 2],
    mem_proofs_prod: [MerkleProofProductions; 2*N - 1],
	rules_com: Field
) {
    assert(parseTreeChecker(string, labels, edges, mem_proofs_prod, rules_com) == true);
}

// fn main(
//     string: [Field; N],
//     labels: [Field; 3*N - 1],
//     edges: [Edge; 3*N - 2],
//     mem_proofs_prod: [Field; 2*N - 1]
// ) {
//     assert(checkMemNaive2(string, labels, edges, mem_proofs_prod) == true);
// }


// fn main(
//     string: [Field; N],
//      apps: [App; 2*N-1]
// ) {
// 	naive_impl(string, apps);
// }


// #[test]
// fn test_check_mem_naive() {
//     assert(checkMemNaive2([a, c, a, c], 
// 	 [S, Ac, Ac, A, C, A, C, a, c, a, c], 
// 	 [Edge::new(0, 1), Edge::new(0, 2),
// 	 Edge::new(1, 3), Edge::new(1, 4), 
// 	 Edge::new(2, 5), Edge::new(2, 6),
// 	 Edge::new(3, 7), Edge::new(4, 8),
// 	 Edge::new(5, 9), Edge::new(6, 10)],
// 	 [0, 2, 2, 3, 4, 3, 4]) == true);
// }
// #[test]
// fn test_main() {
//     main([a, c, a], // [S]
// 	 [(0,0),   // [Ac, A]
// 	  (1,0),   // [A, A, C]
// 	  (2,0), (2,1), (4,2) ]
// /*	 [(0, 0),
// 	  (1, 0),
// 	  (6, 2),
// 	  (4, 3),
// 	  (5, 2),
// 	  (4, 3),
// 	  (3, 2),
// 	  (2, 0),
// 	  (4, 1)]*/);
// }

// global S = 1;
// global Ac = 2;
// global Bc = 3;
// global A = 4;
// global B = 5;
// global C = 6;
// global a = 7;
// global b = 8;
// global c = 9;

// global rules = [
//     (S, Ac, A),  //0 
//     (Ac, A, C),  //1
//     (A, a, 0),   //2
//     (B, b, 0),   //3
//     (C, c, 0),   //4
//     (Bc, B, C),  //5
//     (A, Bc, C),  //6
// ]; 

// struct Node {
//     next: Field,
//     val: Field
// }

// fn main(string: [Field; N], apps: [(Field,Field); 2*N-1]) {

//     // Start with Start symbol    
//     let mut list = [Node{next:-1,val:0}; 2*N-1];
//     list[0].val = S;
//     let mut listHead = 0; // Start of list
//     let mut listNext = 1; // next unallocated node

//     // Apply rules
//     for rl in apps {
// 	let (rule, loc) = rl;
// 	let (nt, ntL, ntR) = rules[rule];
// 	// check rule applies to correct non terminal
// 	assert(list[loc].val == nt);

// 	if (ntR == 0) { // NT to T
// 	    // Replace in place
// 	    list[loc].val = ntL;
// 	} else { // NT to (NT,NT)

// 	    // Add a new node to the end
// 	    list[listNext].val = ntR;
// 	    list[loc].val = ntL;

// 	    // New node points to the next.
// 	    // Modify current node to point to new one
// 	    list[listNext].next = list[loc].next;
// 	    list[loc].next = listNext;
// 	    listNext += 1;
// 	}
//     }

//     // Check final string matches
//     let mut cur = listHead;
//     for i in 0..N {
// 	assert(string[i] == list[cur].val);
// 	cur = list[cur].next;
//     }
//     assert(cur == -1);

// }

// #[test]
// fn test_main() {
//     main([a, c, a], // [S]
// 	 [(0,0),   // [Ac, A]
// 	  (1,0),   // [A, A, C]
// 	  (2,0), (2,1), (4,2) ]
// /*	 [(0, 0),
// 	  (1, 0),
// 	  (6, 2),
// 	  (4, 3),
// 	  (5, 2),
// 	  (4, 3),
// 	  (3, 2),
// 	  (2, 0),
// 	  (4, 1)]*/);
// }
