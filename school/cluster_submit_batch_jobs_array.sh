#!/bin/bash
#
#SBATCH -J COVID_SEIRX_data_creation_array
#SBATCH -N 1         
#SBATCH --array=0-72        
#SBATCH --ntasks-per-core=2
#SBATCH --ntasks=16          
#SBATCH --time=04:00:00      
#SBATCH --mail-type=BEGIN,END
#SBATCH --mail-user=lasser@csh.ac.at

#module purge
#module load anaconda3/5.3.0
#source /opt/sw/x86_64/glibc-2.17/ivybridge-ep/anaconda3/5.3.0/etc/profile.d/conda.sh
#conda deactivate
#conda activate covid


N_runs=500
stype=primary             
max_tasks=32                 ## number of tasks per node.
running_tasks=0              ## initialization
src=/home/lv71526/jlasser/agent_based_simulations/agent_based_COVID_SEIRX/data/school
dst=/global/lv71526/jlasser/results

SLURM_ARRAY_TASK_ID=0

let m_range_start=$SLURM_ARRAY_TASK_ID*4
let m_range_end=$m_range_start+3

for m_start in $(seq $m_range_start $m_range_end)
	do
	let m_end=$m_start+1

	for s_start in $(seq 0 25)
		do
		s_end=`echo $s_start+1 | bc`
		running_tasks=`ps -C python --no-headers | wc -l`
		
		while [ "$running_tasks" -ge "$max_tasks" ]
			do
			sleep 5
			running_tasks=`ps -C python --no-headers | wc -l`
		done

		echo "*********************"
		echo python run_data_creation.py $stype $N_runs $s_start $s_end $m_start $m_end $src $dst &
		echo "*********************"
		sleep 1
	done
done
wait
