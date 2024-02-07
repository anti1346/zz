#!/bin/bash

# 사용 방법을 출력하는 함수
usage() {
    echo "Usage: $0 {build|rm|rmi|inspect|run}" >&2
    exit 1
}

# 명령어가 입력되지 않은 경우 사용 방법을 출력
if [ -z "$1" ]; then
    usage
fi

# 컨테이너 이름과 이미지 이름을 변수로 지정
image_name="anti1346/node-app:latest"
container_name="node-app"

# 입력된 명령어에 따라 동작을 결정
case "$1" in
    build)
        # buildkitd 컨테이너가 없으면 buildx create 명령어 실행
        if ! docker ps | grep -q buildkitd; then
            docker buildx create --use
        fi
        docker buildx build --tag $image_name . --push \
            --platform linux/amd64,linux/arm64 \
            --no-cache
        ;;
    rm)
        docker rm -f $(docker ps -aq --filter="name=$container_name")
        ;;
    rmi)
        docker rmi -f $(docker images -aq --filter=reference='$image_name')
        ;;
    inspect)
        docker inspect $image_name --format='{{.Architecture}}'
        ;;
    run)
        docker run -d -p 3000:3000 --name $container_name --hostname $container_name $image_name
        ;;
    *)
        echo "Invalid option: $1" >&2
        usage
        ;;
esac
