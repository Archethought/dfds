## Start Building Your Own Toolbox

A local registry speeds things up and allows you to commit local versions of your images. Let's begin there.

### Setup a Local Registry

```
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

**State: No images and no running containers**

```
docker pull ubuntu && docker tag ubuntu localhost:5000/ubuntu
docker push localhost:5000/ubuntu
docker rmi localhost:5000/ubuntu
docker pull ubuntu

docker run -i -t  --name sandbox ubuntu /bin/bash
# exit
```

### Images and Containers - Key Commands

**State: Image and stopped container**

```
docker stop sandbox
docker exec -i -t --name sandbox /bin/bash
```

connect fails - container not running, cannot execute

**State: Image and stopped container**

```
docker start sandbox
docker exec -i -t --name sandbox /bin/bash
# 
```

connect success - container can run /bin/bash
keep this container open

### Where does the data go?

In container, touch a file

```
# touch myfile
```

We now have a zero length file

```
docker stop sandbox
docker start sandbox
docker exec -i -t --name sandbox /bin/bash

# ls
myfile
```

We stopped the container, started it and data still there

```
# exit

docker stop sandbox
docker rm sandbox
docker run -i -t --name sandbox /bin/bash

# ls
<nothing here>
# exit
```

We stopped the container, removed it, “run” new one and data is gone

```
docker stop sandbox
docker rm sandbox
```

**Create a Volume map for persisting data**

On your Mac or Windows machine prompt

```
mkdir mydata
docker run -i -t  -v /Users/dixon/working/dfds/mydata:/data --name sandbox ubuntu /bin/bash
```

We are in our container, new directory /data is here

```
# cd /data
# touch myfile
# exit

<Look in your Mac or Windows directory and the file "myflies" should be there>

# cd /Users/dixon/working/dfds/mydata
# ls
myfile
```
N.B. Many images create Volume maps by default for persisting data e.g. registry, mariadb, mysql etc.

**Standard Input and Standard Output**


Simple example: try pushing data into the container and outputting it back to the console

```
echo test | docker run -i busybox cat
```

For safety/complteness, specify which pipes will be accepted.


```
docker run -a stdin -a stdout -i -t ubuntu /bin/bash
```

### Commit your own image versions

Let's say you are working quickly and execute several configuration commands:

```
pip install numpy
pip install scipy
pip install matplotlib
```

Here's where Docker helps you save and version your own sandbox. Using **commit** you can save this version like so:

```
docker commit <containerId> localhost:5000/sandbox:numerics1
```

There is now a new image in your local repo called sandbox, with a version tag reminding you what you did to that container.

### Status commands

In the video, three terminals are up, command and two watch terminals

**Containers with state running**
```
docker ps
```

**Containers with all states**
```
docker ps -a
```

**Containers output formatted**
```
docker ps -a --format "{{.ID}}: {{.Image}} {{.Names}} {{.Status}} {{.Ports}} {{.Command}}"
```

**Containers under watch**
```
watch 'docker ps -a --format "{{.ID}}: {{.Image}} {{.Names}} {{.Status}} {{.Ports}} {{.Command}}"'
```

**Image status**
```
docker images
```

**Image under watch status**
```
watch docker images
```

N.B. "watch" is a Linux command. Mac use Homebrew. Windows use Cygwin.


