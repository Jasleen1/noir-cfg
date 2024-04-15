#!/bin/bash

### Copied and edited from https://github.com/amiller/noir-microbenchmarks/blob/master/sortedlists/run_benchmark.sh

# Clear build folder
rm -r build_circuits
mkdir -p build_circuits

# Loop over sizes
for i in $(seq 2 10)
do

    # Generate a new build/2^{i} folder
    nargo new build_circuits/2^${i}
    pushd build_circuits/2^${i}

    # replace {{N}} in src/main.nr    
    cat ../../src/main.nr | LOG_STR_SIZE=$((2**$i)) envsubst > ./src/main.nr
    
    # Generate the Prover.toml with an array
    python3 ../../generate_benchmark_str.py $(($i)) 2>&1 | tee ./Prover.toml

    # echo >> ./Prover.toml "x = ["    
    # for j in $(seq 1 $((2**i)))
    # do
	# cat >> ./Prover.toml <<EOF
	# ${j},
    # EOF
    # done
    # echo >> ./Prover.toml "]"
    # pwd
    # Run the experiment
    nargo compile
    nargo info | tee ../info_${i}.txt

    { time nargo prove; } 2> ../time_proof_${i}.txt

    popd
done

# Collect results