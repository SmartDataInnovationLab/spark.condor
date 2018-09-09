# Copyright 2017 knowru: see https://github.com/knowru/hello_world_spark/blob/3e7fd67be0deb889824217ad55b2f33fd834cd3b/LICENSE

from pyspark import SparkContext
from operator import add
 
sc = SparkContext()
data = sc.parallelize(list("Hello World"))
counts = data.map(lambda x: (x, 1)).reduceByKey(add).sortBy(lambda x: x[1], ascending=False).collect()
for (word, count) in counts:
    print("{}: {}".format(word, count))
sc.stop()
