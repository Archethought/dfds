## ELK
[Elastic Search](https://www.elastic.co/) - [Logstash](https://www.elastic.co/products/logstash) - [Kanbana](https://www.elastic.co/products/kibana)  
The instructions for running ELK on Docker are [here](http://elk-docker.readthedocs.io/)

### Bug mitigation
Before invoking the container, use:
```
sudo sysctl -w vm.max_map_count=262144
```
Although [issue 111](https://github.com/docker-library/elasticsearch/issues/111) is closed, the problem persists.
The error manifests as 
```
Exception in thread "main" java.lang.RuntimeException: bootstrap checks failed
initial heap size [268435456] not equal to maximum heap size [2147483648]; this can cause resize pauses and prevents mlockall from locking the entire heap
max virtual memory areas vm.max_map_count [65530] likely too low, increase to at least [262144]
```

### Invoke the Container
Simple example
```
sudo docker run -d -p 5601:5601 -p 9200:9200 -p 5044:5044 -v /local/path:/data -it --name elk sebp/elk
```

* /local/path is the directory on your local machine that you want to share with your container
* 5601 (Kibana web interface).
* 9200 (Elasticsearch JSON interface).
* 5044 (Logstash Beats interface, receives logs from Beats such as Filebeat – see the Forwarding logs with Filebeat section).

---
(3/21/2017) There is an [error](https://github.com/docker-library/elasticsearch/issues/111) in the latest elk version; specifying version 521, i.e., "elk:521", avoids this unpleasantry. 
(4/4/2017) The error appears to be resolved.


An alternate, convenient, way to start the seb/elk image as a container, instead of using `docker run ....`, you can also use a "docker compose" file. There is a docker-compose.yaml file in the [dfds/elk](https://github.com/Archethought/dfds/tree/master/elk) repository that looks like this:
```
elk:
  image: sebp/elk:521
  ports:
    - "5601:5601"
    - "9200:9200"
    - "5044:5044"
  volumes:
    # mount the dfds project's elk dir as /data on the container
    # CHANGE THIS to point to where you've downloaded https://github.com/Archethought/dfds/tree/master/elk
    # format LOCAL:CONTAINER, so change LOCAL, leave :/data
    # example:
	- ~/dev/projects/data/dfds/elk:/data
```
(Thank you, Hussain Chinoy, for pointing this out!)

Then, invoke it with the `docker-compose` command:
```
docker-compose up
```
Unfortunately, you apparently have little flexibility on naming the container. For the case above, the container will be named `elk_elk_1`


### Start a logstash pipeline
```
docker exec -it elk_elk_1 /opt/logstash/bin/logstash -f /data/csvPipe_v2.conf
```
This uses the conf file that Hussain modified to correctly merge the blower date and time fields.
Note that you will need to modify this file and above command if you did not mount the repository directory with data to `/data` in the container.

THEN, 
1. Go to a browser on your host machine and bring up the Kibana port: http://localhost:5601. It should default to the management console.
1. Change the filter from `logstash-*` to just `*` and hit return.  You should see a drop down below where you can pick datetime. (See picture below.)
1. Select the `create` button.

![kibana window](https://github.com/Archethought/dfds/blob/master/images/kibana_1a.png "Initial Kibana window")


#### Old, Non-ELK way
Modify `transform.py` `reader` and `writer` variables to specify paths appropriate for your installation. 
```
reader = csv.reader(open("/home/carolyn/data/data.csv"), delimiter=',')
writer = csv.writer(open("/home/carolyn/data/output.csv", "w"), delimiter=',', lineterminator='\n')
```
Execute: 
```
python transform.py
```

Enter the elk container and start logstash (assume "elk_elk_1" is the name of your container):
```
docker exec -it elk_elk_1 /bin/bash
/opt/logstash/bin/logstash -f /data/csvPipe.conf
```
For the command above to work, you need to either copy the conf file into your data directory and execute from there, or otherwise specify the proper paths.
THEN, 
1. Go to a browser on your host machine and bring up the Kibana port: http://localhost:5601. It should default to the management console.
1. Change the filter from 'logstash-*' to just '*' and hit return.  You should see a drop down below where you can pick @timestamp.
1. Select the `create` button.

![kibana window](https://github.com/Archethought/dfds/blob/master/images/kibana_1.png "Initial Kibana window")
