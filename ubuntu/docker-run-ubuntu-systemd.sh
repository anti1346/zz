#!/bin/bash

docker run -d \
--privileged \                                      # 컨테이너에 특권 모드 부여
-p 80:80 \                                          # HTTP 포트 포워딩
-p 443:443 \                                        # HTTPS 포트 포워딩
-p 2222:22 \                                        # SSH 포트 포워딩
-v /etc/localtime:/usr/share/zoneinfo/Asia/Seoul \  # 호스트와 컨테이너의 시간 동기화
--name ubuntu-systemd \                             # 컨테이너 이름 지정
anti1346/ubuntu2204:systemd                         # 이미지와 태그 지정
