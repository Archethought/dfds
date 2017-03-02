sysctl -w vm.max_map_count=262144
docker run --rm -d -m 4g -p 5601:5601 -p 9200:9200 -p 5044:5044 --name elk -v /data:/data sebp/elk
