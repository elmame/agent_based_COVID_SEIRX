#!/bin/bash

uptime
echo -n "start: "
date

N_runs=500
stype=lower_secondary             
max_tasks=128                 ## number of tasks per node.
running_tasks=0              ## initialization
src=/home/jlasser/agent_based_COVID_SEIRX/data/school/representative_schools
dst=/home/jlasser/agent_based_COVID_SEIRX/data/school/results_transmissibility


for trisk in 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2
	do
	
	for m_idx in $(seq 0 287)
		do
		running_tasks=`ps -C python --no-headers | wc -l`
		
		while [ "$running_tasks" -ge "$max_tasks" ]
			do
			sleep 5
			running_tasks=`ps -C python --no-headers | wc -l`
		done

		echo "*********************"
		echo run_data_creation_transmissibility.py $stype $N_runs $m_idx $trisk $src $dst
		python3 run_data_creation_transmissibility.py $stype $N_runs $m_idx $trisk $src $dst &
		echo "*********************"
		sleep 1
		
	done
done
wait
