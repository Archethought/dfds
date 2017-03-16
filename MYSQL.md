# Starting and connecting to a MySQL Docker container

In this exercise we're going to start a Docker container running MySQL, and then show three different ways to connect to the container: from the `mysql` command line to on your local machine, directly on the Docker container that we create here, and finally from a second Docker container.

## Start the MySQL database container

To start with, we need to run the following command:

```
docker run --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=secret -d mysql:8
```

This will pull down the MySQL 8.0 Docker image from the Docker Hub if it hasn't already been pulled down to your system. If you've previously pulled this image down, then the above command will use the local copy of the image.

We are passing several commands to the `docker run` command above. In the table below we describe what each parameter is doing:

| Command | Description |
| --- | --- |
| `--name mysql` | This names our container *mysql*. Giving a name will help identify what the container is being used for, and will be used when running the `docker ps` command. Without passing the in the name, you will be given a random name that uses an adjective followed by an underscore and then a scientists name such as *heuristic_wiles*. |
| `-p 3306:3306` | This will map a port on your local machine to a port in the container. In this case we are mapping both to the same port. If you want to have a different port number on your local machine, you would change the number before the colon. |
| `-e MYSQL_ROOT_PASSWORD=secret` | This passes the `MYSQL_ROOT_PASSWORD` environment variable to the container. This is setting the *root* user password for the *mysql* instance to be the word *secret*. |
| `-d` | This tells docker that we want to run the container in detached mode. This means that the container will end when the root process used to run the container exits. |
| `mysql:8` | This is the name and tag of the image we are going to run. The Docker hub page for the image will list the available tags. Note that the image with a tag of *latest* is not always the most recent version. |

Now that we have our container up and running, we can connect to it.

## Access MySQL in the container by running `mysql` on your local machine

You can connect to your container using the `mysql` command line client, if you have it installed locally on your machine. If you are using `docker-machine` on Windows or Mac, you will need to run the `docker-machine env` command to get your Docker container's IP address and put that in the command in place of the *192.168.99.100* IP address in the following command.

```
mysql --protocol tcp -h 192.168.99.100 -P 3306 -u root -p
```

If you are using Docker for Mac, or Docker for Windows, you will use the following command to connect to the container:

```
mysql --protocol tcp -h localhost -P 3306 -u root -p
```

If you mapped a different local port on your machine, then you will need to use that in place of the *3306* value in the above commands.

No matter which way you the `mysql` command to connect to the MySQL server running in the container, you will be asked for a password. You will type in the password you supplied when creating the container. In this case type in *secret*. Since you're typing in a password this will not be displayed while typing for security reason. You can also supply the password on the command line itself by adding the password right after the `-p` parameter with no spaces between it and the password. Doing this is considered insecure as your password will be stored in your command line history.

If you successfully connect you will see some information about the MySQL server you connected to and will be presented with a `mysql>` prompt.

## Access MySQL in the container by running `mysql` in the container

You can run the `mysql` command line directly in the container using the following `docker exec` statement.

```
mysql exec -it mysql mysql -u root -p
```

We are passing several commands to the `docker exec` command above. In the table below we describe what each parameter is doing:

| Command | Description |
| --- | --- |
| `-it` | This is actually two parameters combined into one. It is the same as if you typed in `-i -t`. You will see this shortcut used frequently for parameters that don't take values. The `-i` means run in interactive mode, and the `-t` means to allocate a pseudo-TTY. |
| `mysql` | The first `mysql` is the name of the container that you are trying to connect to. |
| `mysql -u root -p` | This is the command you want to run in the container and must be the last item in the command. Here we want to run the `mysql` command in the container and pass the user and prompt for the password. |

Windows users using Git Bash (and possibly other terminals) might get an error from the above command stating that it cannot enable TTY. If you get that error, try placing `winpty` at the beginning of the command as follows:

```
winpty docker exec -it mysql mysql -u root -p
```

## Access MySQL in the container by running `mysql` in another Docker container

Finally we can access the MySQL server in our original Docker container from a second docker container.

```
docker run -it --link mysql:mysqlserver --name mysqlclient --rm mysql sh -c 'exec mysql -h mysqlserver -P 3306 -u root -p'
```

This command is a little more involved, but we'll try to explain what each parameter to the `docker run` statement means in the table below.

| Command | Description |
| --- | --- |
| `-it` | This is the same as the previous example where we are running in an interactive TTY session. |
| `--link mysql:mysqlserver` | Here we want to link to our container named *mysql* and we're going to alias it as *mysqlserver*. We'll use this alias later in the command. |
| `--name mysqlclient` | We're naming our new container *mysqlclient*. |
| `--rm` | This will remove the new container once we exit it. This helps from leaving stray containers on your system. |
| `mysql` | This is the image our new container will be based on. |
| `sh -c 'exec mysql -h mysqlerver -P 3306 --protocol tcp -u root -p'` | This is the command that we want to run in our new container. Here we're using the `sh` command to spawn a shell and the passing it the string to execute. In this case we're connecting to the MySQL server running on host *mysqlserver* which is the alias we used in the previous link parameter. |
