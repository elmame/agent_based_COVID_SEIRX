#!/bin/bash

uptime
echo -n "start: "
date

N_runs=500
          
max_tasks=32                 ## number of tasks per node.
running_tasks=0              ## initialization

src=/home/jana/CSH/medical/analysis/nursing_homes/data/school/representative_schools
dst=/home/jana/CSH/medical/analysis/nursing_homes/data/school/results_test_positive_rate


for stype in primary primary_dc
	do
	
	for m_idx in $(seq 0 1)
		do
		running_tasks=`ps -C python --no-headers | wc -l`
		
		while [ "$running_tasks" -ge "$max_tasks" ]
			do
			sleep 5
			running_tasks=`ps -C python --no-headers | wc -l`
		done

		echo "*********************"
		echo run_data_creation_test_positive_rate_primary.py $stype $N_runs $m_idx $src $dst
		python run_data_creation_test_positive_rate_primary.py $stype $N_runs $m_idx $src $dst &
		echo "*********************"
		sleep 1
		
	done
done

wait

echo -n "end: "
date