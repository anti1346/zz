#!/bin/bash

# 사용 방법을 출력하는 함수
usage() {
    echo "Usage: $0 {ps|exec|build|buildx|pull|push|login|search|images|rm|rmi|system_prune|container_prune|image_prune|volume_prune|network_prune}" >&2
    exit 1
}

# 명령어가 입력되지 않은 경우 사용 방법을 출력
if [ -z "$1" ]; then
    usage
fi

# 컨테이너 이름과 이미지 이름을 변수로 지정
container_name="node-app"
image_name="anti1346/node-app"

# 입력된 명령어에 따라 동작을 결정
case "$1" in
    ps)
        docker ps
        ;;
    exec)
        docker exec
        ;;
    build)
        docker build
        ;;
    buildx)
        docker build buildx
        ;;
    pull)
        docker pull
        ;;
    push)
        docker push
        ;;
    login)
        docker login
        ;;
    search)
        docker search
        ;;
    images)
        docker images
        ;;
    rm)
        docker rm -f $(docker ps -aq --filter="name=$container_name")
        ;;
    rmi)
        docker rmi -f $(docker images -aq --filter=reference='$image_name')
        ;;
    system_prune)
        docker system prune
        ;;
    container_prune)
        docker container prune
        ;;
    image_prune)
        docker image prune
        ;;
    volume_prune)
        docker volume prune
        ;;
    network_prune)
        docker network prune
        ;;
    *)
        echo "Invalid option: $1" >&2
        usage
        ;;
esac

### link
# ln -s docker_command.sh /bin/dk
