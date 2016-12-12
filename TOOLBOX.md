## Start Building Your Own Toolbox

### Setting up and using a Local Registry

**Problem:**  Docker downloads are time consuming, bandwidth intensive.  
**Solution:** Use a Local Docker Registry.

A local registry speeds things up and allows you to commit local versions of your images. Let's begin there.

```
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

**Problem:**  How to cache an image in the local registry.  
**Solution:** Use **docker tag** and **docker push** commands to cache an existing image.

```
docker pull ubuntu && docker tag ubuntu localhost:5000/ubuntu
docker push localhost:5000/ubuntu
docker rmi localhost:5000/ubuntu
docker pull ubuntu

docker run -i -t ubuntu /bin/bash
# touch i-was-here
# ls
i-was-here
# exit
```

### Images vs. Containers

Docker Images are used to create Containers.  
Containers come and go, Images remain in the Registry.  

**Problem:**  I ran a container and can't find my files.  
**Solution:** You might have run the image twice. Here's how that happens and how you can avoid that.

We just ran a container using the image **ubuntu** and when we exited the command it stopped. Check to be sure. 

```
docker ps -a
CONTAINER ID    IMAGE       COMMAND          CREATED             STATUS                      PORTS            NAMES
748bbf68455d    ubuntu      "/bin/bash"      17 seconds ago      Exited (0) 12 seconds ago                    gigantic_wright
```

Ok, there it is. Now let's run the ubuntu image as a container again.

```
docker run -i -t ubuntu /bin/bash
# ls i-was-here
```

Hey?!? Where's my stuff?!? The file 'i-was'here' is gone!
Executing **docker run** always creates a **new** container. Observe you now have two containers, not one, that came from the ubuntu image.

```
CONTAINER ID    IMAGE       COMMAND          CREATED             STATUS                      PORTS            NAMES
c58660d8c019    ubuntu      "/bin/bash"      11 minutes ago      Exited (0) 3 seconds ago                     sandbox
748bbf68455d    ubuntu      "/bin/bash"      32 minutes ago      Exited (0) 32 minutes ago                    gigantic_wright
```

**Trick:** If you name your containers in a consistent way (sandbox, datacleaner, tensor...), you might catch yourself trying to create the same container twice, because you will get an error trying to use the same name again.  

**Problem:**  I can't execute a shell in a running container.  
**Solution:** Check to make sure the container is actually running. You cannot **docker exec** and run a command in a stopped container.

```
docker run -i -t --name sandbox ubuntu /bin/bash
# exit
docker exec -i -t sandbox /bin/bash
```
connect fails - container not running, cannot execute

```
docker start sandbox
docker exec -i -t sandbox /bin/bash
```

connect success - container can run /bin/bash  

Keep this container open for data location.

### Understand data locality and movement

**Problem:**  I created data files and am not sure where they actually are. Are files in the container also on available my host file system?  
**Solution:** Container file system is **not** the same as the host filesystem. But files do exist on the container filesystem until that container is removed using **docker rm** or similar.  

Prove this. In the container, touch a file

```
# touch myfile
```

There is now a zero length file inside the container.  
In another terminal, try and search for the file 'myfile' on your host filesystem.  
You have proved it is not on your local filesystem.  

Now, prove 'myfile' stays with the container when it stops and starts again.

```
# exit
docker stop sandbox
docker start sandbox
docker exec -i -t sandbox /bin/bash
# ls
myfile
```

You stopped the container, started it and 'myfile' is still there.

```
# exit
docker stop sandbox
docker rm sandbox
docker run -i -t --name sandbox ubuntu /bin/bash

# ls
<myfile is not here>
# exit
```

You stopped the container with **docker stop**, removed it with **docker rm** and executed **docker run** to create a new container. Because you started a new container the data file 'myfile' is not there. This is a completely new container and filesystem.

```
docker stop sandbox
docker rm sandbox
```

**Problem:**  I have large data sets and don't want to copy them into the container, this double wastes space.  
**Solution:** Create a Docker Volume which maps a directory from the host file system (Windows, Mac, Linux) to the container file system.

**Create a Volume map for persisting data**  

On your Mac or Windows machine prompt, create a folder to hold a test data set. Then start a container with using the -v option to map a Docker Volume from the host filesystem '/Users/dixon/working/dfds/mydata' to the container filesystem '/data'.

```
mkdir mydata
docker run -i -t  -v /Users/dixon/working/dfds/mydata:/data --name sandbox ubuntu /bin/bash
```

The new container has started. Check to see the new directory /data is here. It was created automatically for you by Docker. Create a file in that directory, we want to see if it appears in the host filesystem.

```
# cd /data
# touch myfile
# exit

<Look in your Mac or Windows directory and the file "myfile" should be there>

# cd /Users/dixon/working/dfds/mydata
# ls
myfile
```
N.B. Many images create Volume maps by default for persisting data e.g. registry, mariadb, mysql etc.  

**Standard Input and Standard Output**  

**Problem:**  I want to stream data through the container, sending the output to the next workflow step.  
**Solution:** Use standard input and standard output to push data into and take it out of a container.  

Simple example: try sending data into the container using standard input and outputting it back to the console using the 'cat' command to standard output.  

```
echo test | docker run -i busybox cat
```

You can completely specify which pipes will be accepted.

```
docker run -a stdin -a stdout -i -t ubuntu /bin/bash
```

### Commit your own image versions

**Problem:**  I want to save the work I have done modifying my sandbox and **docker run** that image again in the future.  
**Solution:** Use **docker commit** to create a local version of the image. This is different than creating a new Dockerfile, and is a simple and quick way to save your changes. Use a new Dockerfile when really making something new and repeatable to share.  

Let's say you are working quickly and execute several configuration commands:

```
pip install numpy
pip install scipy
pip install matplotlib
apt-get install python-pip python-dev libmysqlclient-dev 
```

Docker helps you save and version your own sandbox.  
Using **docker commit** you can save your version like so:

```
docker commit <containerId> localhost:5000/sandbox:numerics1
```

There is now a new image in your local repo called sandbox, with a version tag reminding you what you did to that container.  
Imagine your versions:
* sandbox:numpy
* sandbox:mysql
* sandbox:plotter

### Status commands and visualizing your Docker environment

**Problem:**  It's hard to visualize the difference between containers and images and what is in existence.  
**Solution:** Use multiple terminals and the Linux 'watch' command to see changes live as you make them.  

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


