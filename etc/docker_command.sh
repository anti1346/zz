#!/bin/bash

# 사용 방법을 출력하는 함수
usage() {
    echo "Usage: $0 {build|buildx|rm|rmi|inspect|run}" >&2
    exit 1
}

# 명령어가 입력되지 않은 경우 사용 방법을 출력
if [ -z "$1" ]; then
    usage
fi

# 컨테이너 이름과 이미지 이름을 변수로 지정
docker_registry="anti1346"
image_name="node-app"
image_version="latest"

# 입력된 명령어에 따라 동작을 결정
case "$1" in
    build)
        docker build --tag "$docker_registry/$image_name:$image_version" . --no-cache
        ;;
    buildx)
        # buildkitd 컨테이너가 없으면 buildx create 명령어 실행
        if ! docker ps | grep -q buildkitd; then
            docker buildx create --use
        fi
        docker buildx build --tag "$docker_registry/$image_name:$image_version" . --push \
            --platform linux/amd64,linux/arm64 \
            --no-cache
        ;;
    rm)
        docker rm -f "$(docker ps -aq --filter="name=$image_name")"
        ;;
    rmi)
        docker rmi -f "$(docker images -aq --filter=reference="$docker_registry/$image_name")"
        ;;
    inspect)
        docker inspect "$docker_registry/$image_name:$image_version" --format='{{.Architecture}}'
        ;;
    run)
        docker run -d -p 3000:3000 --name "$image_name" --hostname "$image_name" "$docker_registry/$image_name:$image_version"
        ;;
    *)
        echo "Invalid option: $1" >&2
        usage
        ;;
esac
