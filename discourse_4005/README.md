This will start a three node cluster using docker. It uses ziti 1.3.2, docker and docker compose.

Start docker compose (clean up first if starting over):
```
docker compose down -v
docker compose up
```

Exec into controller1:
```
docker exec -it controller1 bash
```

Once in the container start the first controller
```
/init/init.sh
```

Exec into controller 2:
```
docker exec -it controller2 bash
```

Add a member to the cluster:
```
/init/member.sh $(hostname)
```

Exec into controller 3:
```
docker exec -it controller3 bash
```

Add a member to the cluster:
```
/init/member.sh $(hostname)
```