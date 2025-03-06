#!/bin/bash

# 명령어의 인자를 읽어 들임
args=("$@")

# 인자의 수를 출력
echo "The number of arguments is: $#"

# 인자의 목록을 출력
for arg in "${args[@]}"; do
  echo "Argument: $arg"
done

# 인수의 값을 출력
for i in "${!args[@]}"; do
  echo "Argument $i: $args[$i]"
done

