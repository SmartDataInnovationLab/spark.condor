#!/bin/sh
python3 -m venv env
source env/bin/activate
pip install pyspark
# because condor does not like symlinks...
rm env/lib64 
