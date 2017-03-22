### ELK
The instructions for running ELK on Docker are [here](http://elk-docker.readthedocs.io/)

Simple example
```
sudo docker run -d -p 5601:5601 -p 9200:9200 -p 5044:5044 -v /local/path:/data -it --name elk sebp/elk
```

* /local/path is the directory on your local machine that you want to share with your container
* 5601 (Kibana web interface).
* 9200 (Elasticsearch JSON interface).
* 5044 (Logstash Beats interface, receives logs from Beats such as Filebeat – see the Forwarding logs with Filebeat section).
