Submit file and shell script to start Apache Spark in standalone mode on HTCondor

#Prerequisites
* htcondor (vanilla universe)
* python3 pip and venv
* network access between the cluster nodes

#Preperation
Run ```./spark.venv.sh``` to create a python venv with pyspark. 

Note: the script deletes the symlink env/lib64 due the fact that htcondor transfers no symlinks (!?)

#Running Spark in Standalone
run using ``` condor_submit spark.condor -queue [num_workers] ``` 

The default worker size is 8 CPUs and 32G RAM. You may adjust this by using the appropriate ```-a``` flags on submit or editing the job file.

The script is currently activating a conda environment on the target node that is specified using the arguments of the executable.

Note: The master runs on the first worker node

#Accessing the Cluster
The script generates two .url files containing the master url and webui url

You may check if things are working using (bash syntax) e.g. ```w3m $(<spark.webui.url)```

You may submit a job using (bash syntax) e.g. ```spark-submit --master $(<spark.master.url) helloworld.py```

Note: that the python driver runs on the submitting node. So you probably also want to submit it as a job

#Stopping the Cluster
To stop the jobs either call ```./spark.stop.sh``` or manually delete spark.master.url


#Links

* http://research.cs.wisc.edu/htcondor/manual/current/condor_submit.html
* https://spark.apache.org/docs/latest/spark-standalone.html


#Other solutions

* https://github.com/rlmv/spark-condor/
