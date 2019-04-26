# xcpEngine on Argon

This guide is based off of [xcpEngine's own tutorial](https://xcpengine.readthedocs.io/config/tutorial.html)

This a guide for running [xcpEngine](https://xcpengine.readthedocs.io/index.html) on [Argon](https://wiki.uiowa.edu/display/hpcdocs/Argon+Cluster).
xcpEngine is a tool that takes the output from [fmriprep](https://fmriprep.readthedocs.io/en/stable/)
and completes a variety of analytical outputs (e.g. reho, alff, etc) as both niftis and tabular data (i.e. CSVs).
The CSV data is data from a per-region/parcel basis from an atlas.
xcpEngine supports several atlases, so you can get output from several atlas in one run.

The first step will be to log into argon (through a terminal)
```
# example ssh jdkent@argon.hpc.uiowa.edu
ssh <hawkid>@argon.hpc.uiowa.edu
```
and if you're off campus, you can use port 40
```
ssh <hawkid>@argon.hpc.uiowa.edu -p 40
```

While logged into Argon, we will be using the [singularity](https://www.sylabs.io/guides/2.6/user-guide/) 
image of xcpEngine so we can run it on Argon without having to worry about installing all the necessary software.
Even though xcpEngine does not have an image on [singularityhub](https://singularity-hub.org/),
we can build a singularity image from xcpEngine's docker image on [dockerhub](https://hub.docker.com/r/pennbbl/xcpengine).

It's better to build from a tagged version of an image (e.g. `1.0`) instead of `lastest` because `latest` represents
the most current version of the image and everytime they change the image, the `latest` tag will now point to a different image.
If we want to be reproducible (it's all the rage these days), using the tag `1.0` should always point to the same
image across eternity and should always give us the same result.

```
# make a place to keep our singularity images
mkdir -p ${HOME}/simgs
# make our singularity image
singularity build ~/simgs/xcpEngine_v1.0.simg docker://pennbbl/xcpengine:1.0
```

To run xcpEngine, we need data, specifically data that has been processed by fmriprep.
Thankfully, the developers of xcpEngine have provided an example dataset.
```
# url of the data
curl -o fmriprep.tar.gz -SL https://ndownloader.figshare.com/files/13598186
# untar (extract) the data
tar xvf fmriprep.tar.gz
```

Next, we need two files: 1) a design file that defines what steps we want to run on our data
and 2) a cohort file that specifies which participants to run.

```
# download the design file (if necessary)
curl -O https://raw.githubusercontent.com/PennBBL/xcpEngine/master/designs/fc-36p.dsn
```

Here are the internals of the cohort file:
```
id0,img
sub-1,fmriprep/sub-1/func/sub-1_task-rest_space-T1w_desc-preproc_bold.nii.gz
```

All we need now is a directory to place the outputs, then we can run xcpEngine.
```
mkdir -p ./xcp_output
```

Now we are ready to run xcpEngine!
I made a little script to help make a "job" file we can submit to the cluster.
It requires our email address as input:
```
./create_job.sh james-kent@uiowa.edu
```

`create_job.sh` should create a "job" file named `sample_xcpengine.job` that looks like this:
```
#!/bin/bash

#$ -pe smp 6
#$ -q UI
#$ -m bea
#$ -M james-kent@uiowa.edu
#$ -e /Users/jdkent/xcpEngine/fc.err
#$ -o /Users/jdkent/xcpEngine/fc.out

singularity run -H /Users/jdkent/singularity_home \
/Users/jdkent/simgs/xcpEngine_v1.0.simg \
-d /Users/jdkent/xcpEngine/fc-36p.dsn \
-c /Users/jdkent/xcpEngine/func_cohort.csv \
-o /Users/jdkent/xcpEngine/xcp_output \
-t 1 -r /Users/jdkent/xcpEngine
```

and we can submit `sample_xcpengine.job` to the cluster using:
```
qsub sample_xcpengine.job
```

We will get an email when the job starts and finishes.

And you're done running it!

TODO: analyze the outputs

