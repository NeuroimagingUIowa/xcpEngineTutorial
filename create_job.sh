#!/bin/bash

email=$1

echo "\
#!/bin/bash

#$ -pe smp 6
#$ -q UI
#$ -m bea
#$ -M ${email}
#$ -e ${PWD}/fc.err
#$ -o ${PWD}/fc.out

singularity run -H ${HOME}/singularity_home \
${HOME}/simgs/xcpEngine_v1.0.simg \
-d ${PWD}/fc-36p.dsn \
-c ${PWD}/func_cohort.csv \
-o ${PWD}/xcp_output \
-t 1 -r ${PWD}
" > sample_xcpengine.job
