#!/bin/bash
#$ -S /bin/bash
#$ -l h_vmem=4G
#$ -l h_rt=01:00:00
#$ -t 1:30
#$ -cwd
#$ -o $HOME/log
#$ -e $HOME/log

. /etc/profile

module add matlab

matlab -nodisplay -nojvm -r Sim_03_500_subjects

