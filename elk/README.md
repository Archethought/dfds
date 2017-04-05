## ELK
[Elastic Search](https://www.elastic.co/) - [Logstash](https://www.elastic.co/products/logstash) - [Kanbana](https://www.elastic.co/products/kibana)  
The instructions for running ELK on Docker are [here](http://elk-docker.readthedocs.io/)


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
(3/21/2017) There is an error in the latest elk version; specifying version 521, i.e., "elk:521", avoids this unpleasantry. 
(4/4/2017) The error appears to be resolved.


An alternate, convenient, way to start the seb/elk image as a container, instead of using `docker run ....`, you can also use a "docker compose" file. There is a docker-compose.yaml file in the [dfds/elk](https://github.com/Archethought/dfds/tree/master/elk) repository.
Create a file named `docker-compose.yml` (It's a YAML file), that looks like this:
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
Unfortunately, you apparently have little flexibility on naming the container. For the case above, the container will be named `elk_elk_1'

### Parse the sample log file
Modify `transform.py` `reader` and `writer` variables to specify paths appropriate for your installation. 
```
reader = csv.reader(open("/home/carolyn/data/data.csv"), delimiter=',')
writer = csv.writer(open("/home/carolyn/data/output.csv", "w"), delimiter=',', lineterminator='\n')
```

Execute: 
```
python transform.py
```

### Start a logstash pipeline
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
