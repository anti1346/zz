
### 히스토리
```
echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> ~/.bashrc
```
```
source ~/.bashrc
```
### 프롬프트
```
vim ~/.bashrc
```
```
export PS1="\[\e[33m\]\u\[\e[m\]\[\e[37m\]@\[\e[m\]\[\e[34m\]\h\[\e[m\]:\[\033[01;31m\]\W\[\e[m\]$ "
```

```
source ~/.bashrc
