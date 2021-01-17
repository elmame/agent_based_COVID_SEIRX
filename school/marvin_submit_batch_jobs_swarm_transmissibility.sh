#!/bin/bash

uptime
echo -n "start: "
date

N_runs=500

trisk=1.5           
max_tasks=32                 ## number of tasks per node.
running_tasks=0              ## initialization
src=/home/lasser/agent_based_covid/agent_based_COVID_SEIRX/data/school/representative_schools
dst=/home/lasser/agent_based_covid/agent_based_COVID_SEIRX/data/school/results_transmissibility


for stype in secondary primary_dc lower_secondary_dc secondary_dc
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
		python run_data_creation_transmissibility.py $stype $N_runs $m_idx $trisk $src $dst &
		echo "*********************"
		sleep 1
		
	done
done
wait

echo -n "end: "
date