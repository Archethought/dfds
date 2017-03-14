### Run mysql commands
**start the database**

```
docker run --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=secret -d mysql:8
```

**access the mysql command line (Docker for Mac you may use 'localhost')**

```
mysql -u root -h 192.168.99.100 -P 3306 --protocol=tcp  -p
```

**Connect to it using Docker Container**

```
docker run -it --link mysql:mysql --name mysqlclient --rm mysql sh -c 'exec mysql -h"192.168.99.100" -P"3306" -uroot -p"secret"'
```

