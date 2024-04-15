import sys 

def stringify_calculated_arr(input_arr):
    # Assumes input array has length at least 1
    out_str = "[ "
    input_len = len(input_arr)
    for i in range(input_len - 1):
        out_str = out_str + str(input_arr[i]) + ', '
    out_str = out_str + str(input_arr[input_len - 1]) + ']'
    return out_str


# Computes an array of the form [a, c, ..., a, c] of length 2^n where n >= 1
def calculate_str_in_g1(n):
    out_arr = []
    for i in range((2**(n-1))):
        out_arr = out_arr + ["\"5\"", "\"6\""]
    return out_arr

# Computes the transformations needed to parse a string of length 2^n for n >= 1
def calculate_transformations_for_g1_rev_ord(n):
    single_ac_arr = ["[[apps]]\n position=0\n rule=3\n", "[[apps]]\n position=1\n rule=4\n"]
    if n == 1:
        return ["[[apps]]\n position=0\n rule=5\n"] + single_ac_arr
    # Always start with this if n > 1
    transformations = ["[[apps]]\n position=0\n rule=0\n"]#[(0, 0)]
    str_len = 2**n
    num_pairs = 2**(n-1) 
    first_set = ["[[apps]]\n position=1\n rule=2\n", "[[apps]]\n position=1\n rule=3\n", "[[apps]]\n position=2\n rule=4\n"]#["[[apps]]\n rule=1\n position=2\n", (1, 3), (2, 4)]
    last_set = ["[[apps]]\n position=0\n rule=2\n"] + single_ac_arr
    middle_set = ["[[apps]]\n position=0\n rule=1\n"] + first_set
    transformations = transformations + first_set
    # only get here if n > 1, so this should be non-negative
    for i in range(num_pairs - 2):
        transformations = transformations + middle_set
    transformations = transformations + last_set
    return transformations

def make_transformation_string(pos, rule):
    return "[[apps]]\n position=" + str(pos) + "\n rule=" + str(rule) + "\n" 

# Computes the transformations needed to parse a string of length 2^n for n >= 1
def calculate_transformations_for_g1(n):
    str_len = 2**n
    num_pairs = 2**(n-1) 
    transformations = []
    
    if n == 1:
        transformations = transformations + [(0, 5)]
        append_list = [(0, 2),
                       (0, 3),
                       (1, 4),
                       ]
        return transformations + append_list
    for i in range(num_pairs):
        if i == 0:
            transformations = transformations + [(0, 0)]
        elif i < num_pairs - 1:
            transformations = transformations + [(2*i, 1)]
        append_list = [(2*i, 2),
                       (2*i, 3),
                       (2*i + 1, 4),
                       ]
        transformations = transformations + append_list

    return transformations

S = 1
Ac = 2
A = 3
C = 4
a = 5
c = 6

g_1_rules = [
    (S, Ac, Ac),  #0 
    (Ac, Ac, Ac), #1
    (Ac, A, C),   #2
    (A, a, 0),   #3
    (C, c, 0),   #4
    (S, A, C),  #5
]; 

class Node:
    def __init__(self) -> None:
        self.next = 0
        self.val = 0
    
    def __eq__(self, other: object) -> bool:
        return ((self.next == other.next) and (self.val == other.val))
        
    def new_node(next, val):
        new_node = Node()
        new_node.next = next
        new_node.val = val
        return new_node
    
    def print(self):
        print("next = " + str(self.next) + ", val = " + str(self.val))

def print_state_arr(arr_of_nodes):
    for node in arr_of_nodes:
        node.print()


def find_loc(lst, loc):
    physical_loc = 0
    curr_node = lst[0]
    traversed = 0
    while (curr_node.next != 0):
        if traversed == loc:
            break
        else:
            curr_node = lst[curr_node.next]
        traversed = traversed + 1
    for (pos, node) in enumerate(lst):
        if node == curr_node:
            return pos
    return physical_loc
        
        
def mutate_locs_for_g1(transformations):
    # transformations are tuples representing (position, rule)
    # However, in the function to generate said transformations, we 
    # use the logical position of a node, which won't work in the SNARK
    # so we use this function to mutate the logical locations to physical locations.
    state_linked_list = [Node.new_node(0, 1)]
    transformation_list = []
    list_next = 1
    for rl in transformations:
        rule = rl[1]
        loc = rl[0]
        physical_pos = find_loc(state_linked_list, loc)
        transformation_list.append((physical_pos, rule))
        (nt, ntL, ntR) = g_1_rules[rule]
        if (ntR == 0):
            state_linked_list[physical_pos].val = ntL
        else:
            state_linked_list.append(Node.new_node(state_linked_list[physical_pos].next, ntR))
            state_linked_list[physical_pos].next = list_next
            state_linked_list[physical_pos].val = ntL
            list_next += 1
    return transformation_list





input_len_from_sys = int(sys.argv[1])
test_str = calculate_str_in_g1(input_len_from_sys)
test_transform = mutate_locs_for_g1(calculate_transformations_for_g1(input_len_from_sys))
print("string = " + stringify_calculated_arr(test_str) + "\n")
for trans in test_transform:
    print(make_transformation_string(trans[0], trans[1]))

