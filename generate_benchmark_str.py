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
        transformations = transformations + [make_transformation_string(0, 5)]
        append_list = [make_transformation_string(0, 2),
                       make_transformation_string(0, 3),
                       make_transformation_string(1, 4),
                       ]
        return transformations + append_list
    for i in range(num_pairs):
        if i == 0:
            transformations = transformations + [make_transformation_string(0, 0)]
        elif i < num_pairs - 1:
            transformations = transformations + [make_transformation_string(2*i, 1)]
        append_list = [make_transformation_string(2*i, 2),
                       make_transformation_string(2*i, 3),
                       make_transformation_string(2*i + 1, 4),
                       ]
        transformations = transformations + append_list

    return transformations

input_len_from_sys = int(sys.argv[1])
test_str = calculate_str_in_g1(input_len_from_sys)
test_transform = calculate_transformations_for_g1(input_len_from_sys)
print("string = " + stringify_calculated_arr(test_str) + "\n")
for trans in test_transform:
    print(trans)

