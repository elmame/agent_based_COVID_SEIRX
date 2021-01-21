#!/bin/bash

uptime
echo -n "start: "
date

N_runs=500
stype=secondary             
max_tasks=220                 ## number of tasks per node.
running_tasks=0              ## initialization
src=/home/jlasser/agent_based_COVID_SEIRX/data/school/
dst=/home/jlasser/agent_based_COVID_SEIRX/data/school/results

for s_idx in $(seq 0 9)
	do
	
	for m_idx in $(seq 0 287)
		do
		running_tasks=`ps -C python3 --no-headers | wc -l`
		
		while [ "$running_tasks" -ge "$max_tasks" ]
			do
			sleep 5
			running_tasks=`ps -C python3 --no-headers | wc -l`
		done

		echo "*********************"
		echo run_data_creation_extended_secondary.py $stype $N_runs $s_idx $m_idx $src $dst
		python3 run_data_creation_extended_secondary.py $stype $N_runs $s_idx $m_idx $src $dst &
		echo "*********************"
		sleep 1
		
	done
done
wait
