#!/bin/sh -x
source env/bin/activate

CONDOR_CHIRP=`condor_config_val LIBEXEC`/condor_chirp

HOSTNAME=`hostname`
PORT=`python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()'`
#Uncomment if you want to run multiple clusters CLUSTER=`$CONDOR_CHIRP get_job_attr ClusterId`
MEM=`$CONDOR_CHIRP get_job_attr RequestMemory`

function finish
{
	[ ! -z $WORKER ] && kill $WORKER && wait $WORKER
	[ ! -z $MASTER ] && kill $MASTER && wait $MASTER

	[ ! -z $MASTER ] && $CONDOR_CHIRP remove spark-webui${CLUSTER}.url
}
trap finish exit

if echo spark://$HOSTNAME:$PORT | $CONDOR_CHIRP  put -perm 600 -mode cwx - spark-master${CLUSTER}.url
then
    WEBUI=`python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()'`
    echo http://$HOSTNAME:$WEBUI | $CONDOR_CHIRP  put -perm 600 -mode cw - spark-webui${CLUSTER}.url
    spark-class org.apache.spark.deploy.master.Master --host $HOSTNAME --port $PORT --webui-port $WEBUI &
    MASTER=$!
fi

while 
MasterAddress=`$CONDOR_CHIRP fetch spark-master${CLUSTER}.url -`
echo $MasterAddress|grep -v spark://
do sleep 5; done 

spark-class org.apache.spark.deploy.worker.Worker -m ${MEM}M --webui-port 0 $MasterAddress &
WORKER=$!

while $CONDOR_CHIRP fetch spark-master${CLUSTER}.url - >/dev/null
do sleep 30; done
