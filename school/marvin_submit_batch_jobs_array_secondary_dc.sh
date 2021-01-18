#!/bin/bash


N_runs=500
stype=secondary_dc             
max_tasks=32                 ## number of tasks per node.
running_tasks=0              ## initialization
src=/home/lasser/agent_based_covid/agent_based_COVID_SEIRX/data/school/
dst=/home/lasser/agent_based_covid/agent_based_COVID_SEIRX/data/school/results

for s_idx in $(seq 0 14)
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
		echo run_data_creation.py $stype $N_runs $s_idx $m_idx $src $dst
		python run_data_creation.py $stype $N_runs $s_idx $m_idx $src $dst &
		echo "*********************"
		sleep 1
	done
done
wait
