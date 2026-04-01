# AI/SW 개발 워크스테이션 구축

## 1. 프로젝트 개요

이 저장소는 Codyssey week1 기본 과제 결과물을 정리한 저장소입니다. 목표는 터미널 기본 조작, 파일 권한, Docker 실행 환경, Dockerfile 기반 커스텀 이미지, 포트 매핑, 바인드 마운트, Docker 볼륨, Git/GitHub 연동까지를 직접 수행하고, 그 결과를 README와 로그 및 스크린샷으로 재현 가능하게 남기는 것입니다.

이번 과제에서 특히 확인하려고 한 구조는 아래와 같습니다.

- 터미널로 파일과 디렉토리를 직접 다룰 수 있는가
- 권한이 어떻게 해석되고 왜 필요한지 설명할 수 있는가
- 이미지와 컨테이너의 차이를 이해하고 기존 이미지를 기반으로 커스텀 이미지를 만들 수 있는가
- 포트 매핑, 바인드 마운트, 볼륨이 각각 어떤 문제를 해결하는지 설명할 수 있는가
- Git과 GitHub를 로컬 버전 관리와 원격 협업 플랫폼으로 구분해서 설명할 수 있는가

## 2. 실행 환경

- 호스트 OS: `macOS 26.4`
- 호스트 Shell: `zsh`
- 호스트 Terminal: iTerm2
- Docker Runtime: OrbStack
- Docker Version: `28.5.2`
- Git Version: `2.50.1`

이번 과제는 Docker 기반 실습이 핵심이므로, 애플리케이션이 실제로 실행되는 컨테이너 환경과 과제를 수행한 호스트 환경을 구분해서 기록했습니다. Docker는 호스트 OS 의존성을 줄이기 위한 도구이지만, README의 실행 환경 항목에는 실제로 어떤 환경에서 실습했는지도 함께 남기는 것이 맞다고 판단했습니다.

- 컨테이너 실습 이미지: `ubuntu:24.04` (`Ubuntu 24.04.4 LTS`)
- 커스텀 웹 서버 베이스 이미지: `nginx:1.29.7-alpine` (`NGINX 1.29.7`, `Alpine Linux 3.23.3`)

재현성을 높이기 위해 커스텀 이미지 제작과 주요 실습 이미지에는 `latest` 같은 가변 태그 대신 고정 태그를 사용했습니다. 이번 문서에서는 `ubuntu:24.04`, `nginx:1.29.7-alpine`처럼 버전이 고정된 태그를 기준으로 기록했습니다. `hello-world`는 설치 점검용 공식 예시 이미지라 기본 태그를 그대로 사용했습니다.

서울캠퍼스 환경에서는 `sudo` 사용이 제한될 수 있어 OrbStack을 사용했습니다. OrbStack이 실행 중이면 터미널에서는 일반 Docker 환경과 동일하게 `docker` 명령을 사용할 수 있습니다.

### 2-1. 주요 명령어 설명

아래 명령어들은 README 전반에서 반복해서 사용되므로, 의미를 먼저 정리했습니다.

- `pwd`: 현재 내가 서 있는 폴더의 전체 경로를 보여 주는 명령어입니다.
- `ls -la`: 현재 폴더의 파일과 디렉토리 목록을 자세히 보여 주는 명령어입니다. `-a`는 숨김 파일까지 포함한다는 뜻입니다.
- `chmod`: 파일이나 디렉토리의 권한을 바꾸는 명령어입니다.
- `docker build`: Dockerfile을 읽어서 새로운 이미지를 만드는 명령어입니다.
- `docker run`: 이미지를 실제 컨테이너로 실행하는 명령어입니다.
- `docker exec`: 이미 실행 중인 컨테이너 안에서 추가 명령을 실행하는 명령어입니다.
- `docker ps`: 현재 실행 중인 컨테이너 목록을 보는 명령어입니다.
- `docker logs`: 컨테이너가 출력한 로그를 확인하는 명령어입니다.
- `docker volume create`: Docker가 관리하는 별도의 저장공간인 볼륨을 만드는 명령어입니다.
- `curl`: 브라우저 대신 터미널에서 웹 주소에 요청을 보내고, 응답 내용을 바로 확인하는 명령어입니다.
- `git config --list`: 현재 Git 설정값을 한 번에 확인하는 명령어입니다.

옵션도 같이 보면 이해가 쉬워집니다.

- `-p 8080:80`: 호스트의 8080 포트를 컨테이너의 80 포트와 연결한다는 뜻입니다.
- `-v 호스트경로:컨테이너경로`: 내 컴퓨터의 폴더를 컨테이너 안 경로와 연결한다는 뜻입니다.
- `-d`: 컨테이너를 백그라운드에서 실행한다는 뜻입니다.

### 2-2. 이미지 이름 정리

이번 과제에서는 `ubuntu`, `nginx`, `alpine`이 각각 다른 역할로 등장해서 처음 보면 헷갈릴 수 있습니다. 그래서 아래처럼 구분해서 이해하시면 됩니다.

Docker 이미지와 Docker 볼륨도 역할이 다릅니다. Docker 이미지는 컨테이너를 만들기 위한 실행 템플릿이고, Docker 볼륨은 컨테이너가 사용하거나 남겨야 하는 데이터를 저장하는 공간입니다.

- `ubuntu:24.04`: 리눅스 컨테이너 실습과 볼륨 영속성 검증에 사용한 이미지입니다.
- `nginx:1.29.7-alpine`: 웹 서버용 베이스 이미지입니다.
- `nginx`: 웹 서버 프로그램 이름입니다.
- `1.29.7`: 사용한 NGINX 버전입니다.
- `alpine`: NGINX가 올라가 있는 가벼운 리눅스 배포판 이름입니다.
- `codyssey-web:1.0`: 제가 [Dockerfile](Dockerfile)로 직접 빌드한 커스텀 이미지 이름입니다.

즉 `nginx:1.29.7-alpine`은 `nginx`와 `alpine`이 따로 놀고 있는 것이 아니라, "Alpine Linux 위에 올라간 NGINX 1.29.7 이미지"라고 이해하시면 됩니다. 그리고 이 베이스 이미지 위에 제 HTML 파일을 복사해서 만든 최종 결과가 `codyssey-web:1.0`입니다.

## 3. 수행 체크리스트

- [x] 제출 저장소와 README 준비
- [x] 터미널 기본 조작 기록
- [x] 권한 변경 실습 기록
- [x] Docker 설치 및 기본 점검
- [x] Docker 기본 운영 명령 기록
- [x] `hello-world` 실행 기록
- [x] `ubuntu` 컨테이너 내부 명령 기록
- [x] Dockerfile 기반 커스텀 이미지 제작
- [x] 포트 매핑 접속 증거
- [x] 바인드 마운트 변경 전/후 증거
- [x] Docker 볼륨 영속성 증거
- [x] Git 설정 기록
- [x] VS Code 저장소 연동 증거
- [x] 트러블슈팅 2건 이상 정리

## 4. 결과물 위치

- README: [README.md](README.md)
- Dockerfile: [Dockerfile](Dockerfile)
- 웹 소스: [site/index.html](site/index.html)
- 로그 폴더: [docs/logs](docs/logs)
- 스크린샷 폴더: [docs/screenshots](docs/screenshots)

## 5. 터미널 기본 조작

터미널에서는 현재 위치 확인, 숨김 파일 포함 목록 확인, 디렉토리 생성, 디렉토리 이동, 빈 파일 생성, 파일 내용 확인, 복사, 이동 및 이름 변경, 삭제를 수행했습니다.

```bash
$ pwd
$ ls -la
$ mkdir -p practice/terminal-log/archive
$ cd practice/terminal-log
$ touch empty.txt
$ printf "hello codyssey week1\n" > memo.txt
$ cat memo.txt
$ cp memo.txt copy.txt
$ mv copy.txt archive/memo-renamed.txt
$ ls -la archive
$ rm archive/memo-renamed.txt
```

```text
/Users/ilim/Desktop/codyssey/week1/cs_1
/Users/ilim/Desktop/codyssey/week1/cs_1/practice/terminal-log
hello codyssey week1
-rw-r--r-- empty.txt
-rw-r--r-- memo-renamed.txt
```

절대 경로는 루트(`/`)부터 시작하는 전체 경로이고, 상대 경로는 현재 작업 디렉토리를 기준으로 해석되는 경로입니다. 예를 들어 `/Users/ilim/Desktop/codyssey/week1/cs_1/site/index.html`은 절대 경로이고, 현재 저장소 루트 기준 `site/index.html`은 상대 경로입니다. Docker 볼륨이나 바인드 마운트처럼 경로를 정확히 지정해야 하는 작업에서는 이 차이를 이해해야 경로 실수를 줄일 수 있습니다.

- 증거 로그: [01-terminal-basic.txt](docs/logs/01-terminal-basic.txt)

## 6. 권한 실습

파일 1개와 디렉토리 1개를 만들고 `ls -l`로 변경 전후 권한을 비교했습니다.

```bash
$ ls -l
$ chmod 755 script.sh
$ chmod 700 private-dir
$ ls -l
```

```text
-rw-r--r-- script.sh
drwxr-xr-x private-dir

-rwxr-xr-x script.sh
drwx------ private-dir
```

권한의 기본 단위는 `r`, `w`, `x`입니다.

`r`은 read, 즉 읽기 권한을 의미합니다.

`w`는 write, 즉 쓰기 권한을 의미합니다.

`x`는 execute, 즉 실행 권한을 의미합니다.

숫자 표기는 이 세 권한을 비트처럼 더해서 만듭니다.

`r=4`, `w=2`, `x=1`이므로 `7`은 `4+2+1`이라 `rwx`, `6`은 `rw-`, `5`는 `r-x`, `4`는 `r--`가 됩니다.

따라서 `755`는 소유자 `rwx`, 그룹 `r-x`, 기타 사용자 `r-x`이고, `644`는 소유자 `rw-`, 그룹 `r--`, 기타 사용자 `r--`입니다.

파일에서 `x`는 실행 가능 여부를 의미합니다.

디렉토리에서 `x`는 그 디렉토리 안으로 들어가거나 내부 항목에 접근할 수 있는 권한을 뜻합니다.

- 증거 로그: [02-permissions.txt](docs/logs/02-permissions.txt)

## 7. Docker 설치 및 기본 점검

Docker CLI와 Docker daemon이 모두 정상 동작하는지 점검했습니다. 여기서 daemon은 사용자가 직접 화면으로 조작하는 프로그램이 아니라, 백그라운드에서 계속 실행되면서 실제 작업을 처리하는 프로그램을 뜻합니다. Docker에서는 이 daemon이 실제로 이미지를 관리하고 컨테이너를 실행합니다.

```bash
$ docker --version
$ docker info
```

```text
Docker version 28.5.2
Operating System: OrbStack
Name: orbstack
```

`docker --version`은 CLI 설치 여부를 확인하고, `docker info`는 실제 엔진이 떠 있는지 확인합니다. 둘 중 하나만 성공하면 충분하지 않습니다. 예를 들어 CLI만 있고 daemon이 내려가 있으면 이미지 빌드와 컨테이너 실행은 모두 실패합니다.

- 증거 로그: [03-docker-check.txt](docs/logs/03-docker-check.txt)

## 8. Docker 기본 운영 명령

이미지 목록, 실행 중인 컨테이너, 전체 컨테이너, 로그, 리소스 사용량을 확인했습니다.

```bash
$ docker images
$ docker ps
$ docker ps -a
$ docker logs <container>
$ docker stats --no-stream
```

```text
REPOSITORY    TAG       IMAGE ID
hello-world   latest    ...

CONTAINER ID   IMAGE         STATUS
...            hello-world   Exited (0)
```

이 단계의 목적은 단순 실행이 아니라 운영 관점의 확인 루틴을 익히는 것입니다. `docker images`는 로컬 이미지 저장 상태를, `docker ps`는 실행 중인 컨테이너를, `docker ps -a`는 종료된 컨테이너까지 포함한 전체 상태를 보여 줍니다. `docker logs`는 컨테이너 내부 표준 출력과 에러를 읽을 때 사용하고, `docker stats`는 CPU와 메모리 사용량을 점검할 때 사용합니다.

- 증거 로그: [04-docker-ops.txt](docs/logs/04-docker-ops.txt)

## 9. `hello-world`와 `ubuntu` 컨테이너 실습

먼저 `hello-world`를 실행해 Docker 엔진이 이미지를 내려받고 컨테이너를 생성해 출력 후 종료하는 흐름을 확인했습니다. 그 다음 `ubuntu` 컨테이너를 실행하고 내부에서 `ls`, `echo`를 실행했습니다.

```bash
$ docker run --name hello-check hello-world
$ docker run -d --name ubuntu-lab ubuntu:24.04 sleep infinity
$ docker exec ubuntu-lab ls
$ docker exec ubuntu-lab bash -lc "echo inside-container"
```

```text
Hello from Docker!
inside-container
```

`hello-world`는 메인 프로세스가 메시지를 출력하고 즉시 종료되므로 `Exited (0)` 상태가 됩니다. 반대로 `ubuntu`는 실행 방식에 따라 살아 있을 수도 있고 바로 종료될 수도 있습니다. `attach`는 컨테이너의 메인 프로세스에 직접 붙는 방식이고, `exec`는 이미 실행 중인 컨테이너 안에 새 프로세스를 추가로 실행하는 방식입니다. 이번 과제에서는 `exec`로 내부 명령 실행을 확인했습니다.

- 증거 로그: [05-hello-world.txt](docs/logs/05-hello-world.txt)
- 증거 로그: [06-ubuntu-exec.txt](docs/logs/06-ubuntu-exec.txt)

## 10. 기존 Dockerfile 기반 커스텀 이미지 제작

기존 베이스 이미지는 `nginx:1.29.7-alpine`을 선택했습니다. 이유는 웹 서버 기능이 이미 검증된 상태이고, 과제 요구사항인 정적 웹 콘텐츠 제공, 포트 매핑, 바인드 마운트 실습을 가장 단순하게 설명할 수 있기 때문입니다.

적용한 커스텀 포인트는 아래와 같습니다.

- `LABEL`: 이미지 메타데이터를 붙여 어떤 이미지인지 식별하기 쉽게 했습니다.
- `ENV APP_MODE=required`: 환경 변수 예시를 남겼습니다.
- `COPY site/ /usr/share/nginx/html/`: 제가 만든 정적 HTML을 NGINX 기본 웹 루트에 복사했습니다.
- `EXPOSE 80`: 컨테이너 내부 서비스 포트를 문서화했습니다.

```dockerfile
FROM nginx:1.29.7-alpine

LABEL org.opencontainers.image.title="codyssey-week1-web"
LABEL org.opencontainers.image.description="Week1 custom nginx image"

ENV APP_MODE=required
COPY site/ /usr/share/nginx/html/
EXPOSE 80
```

```bash
$ docker build -t codyssey-web:1.0 .
$ docker run -d --name codyssey-web-8080 -p 8080:80 codyssey-web:1.0
$ docker ps
```

```text
codyssey-web:1.0 build success
0.0.0.0:8080->80/tcp
```

이미지는 실행 설계도이고, 컨테이너는 그 이미지를 실제로 실행한 인스턴스입니다. 따라서 같은 이미지를 기반으로 이름과 포트만 바꿔 여러 컨테이너를 만들 수 있습니다.

- 소스 파일: [site/index.html](site/index.html)
- Dockerfile: [Dockerfile](Dockerfile)
- 증거 로그: [07-build-run.txt](docs/logs/07-build-run.txt)

## 11. 포트 매핑 접속 증거

컨테이너 내부의 80번 포트는 제 Mac 브라우저에서 바로 접근할 수 없습니다. 그래서 `-p 8080:80` 형태의 포트 매핑이 필요합니다. 이 설정은 호스트의 8080 포트 요청을 컨테이너의 80 포트로 전달합니다.

```bash
$ docker run -d -p 8080:80 --name codyssey-web-8080 codyssey-web:1.0
$ curl http://localhost:8080
```

```text
<h1>Codyssey Week1 Custom Web Server</h1>
<p>Mode: required-assignment</p>
```

브라우저 접속 증거는 주소창과 포트가 함께 보여야 한다는 PDF 요구사항에 맞춰 캡처했습니다.

- 증거 로그: [08-port-check.txt](docs/logs/08-port-check.txt)
- 브라우저 캡처: [08-browser-8080.png](docs/screenshots/08-browser-8080.png)

## 12. 바인드 마운트와 볼륨 영속성

### 12-1. 바인드 마운트

바인드 마운트는 호스트 파일을 컨테이너 내부 경로에 직접 연결하는 방식입니다. 이미지에 파일을 다시 복사하지 않아도, 호스트 파일을 수정하면 컨테이너 결과가 즉시 바뀐다는 점을 확인했습니다.

```bash
$ docker run -d --name bind-web -p 8081:80 -v "$(pwd)/site:/usr/share/nginx/html" nginx:1.29.7-alpine
$ curl http://localhost:8081
# host file 수정
$ curl http://localhost:8081
```

```text
Mode: before-bind-mount-change
Mode: after-bind-mount-change
```

현재 저장소의 [site/index.html](site/index.html)은 바인드 마운트 실습이 끝난 뒤의 최종 상태입니다. 따라서 8080 포트에서 확인한 커스텀 이미지 내용과 현재 파일 내용이 다를 수 있는데, 그 이유는 8080 컨테이너는 변경 전 파일로 이미 빌드된 이미지를 사용했고, 8081은 호스트 파일을 실시간으로 읽었기 때문입니다.

- 증거 로그: [09-bind-mount.txt](docs/logs/09-bind-mount.txt)
- 변경 전 캡처: [09-bind-before.png](docs/screenshots/09-bind-before.png)
- 변경 후 캡처: [10-bind-after.png](docs/screenshots/10-bind-after.png)

### 12-2. Docker 볼륨 영속성

볼륨은 컨테이너 외부에 데이터를 두는 Docker 관리 저장공간입니다. 컨테이너를 삭제해도 볼륨 자체를 삭제하지 않으면 데이터는 남습니다.

```bash
$ docker volume create mydata
$ docker run -d --name vol-test -v mydata:/data ubuntu:24.04 sleep infinity
$ docker exec vol-test bash -lc "echo hi > /data/hello.txt && cat /data/hello.txt"
$ docker rm -f vol-test
$ docker run -d --name vol-test2 -v mydata:/data ubuntu:24.04 sleep infinity
$ docker exec vol-test2 bash -lc "cat /data/hello.txt"
```

```text
hi
hi
```

이 결과는 컨테이너 수명과 데이터 수명이 분리될 수 있음을 보여 줍니다. 바인드 마운트가 호스트 폴더 공유라면, 볼륨은 Docker가 관리하는 영속 저장소입니다.

- 증거 로그: [10-volume.txt](docs/logs/10-volume.txt)

## 13. Git 설정 및 GitHub / VS Code 연동

Git 사용자 정보와 원격 저장소 연결 상태를 확인했습니다. 이 저장소에서는 글로벌 설정이 아니라 로컬 설정을 사용했고, 실제 `user.name`, `user.email` 값은 개인정보 보호를 위해 README와 로그에서 마스킹했습니다.

```bash
$ git config --list
$ git remote -v
```

```text
user.name=<masked>
user.email=<masked>
origin  https://github.com/zxcv718/cs_1.git
```

Git은 제 컴퓨터에서 커밋 이력을 관리하는 로컬 버전 관리 도구이고, GitHub는 그 저장소를 원격으로 공유하고 협업하는 플랫폼입니다. 즉 Git은 도구이고 GitHub는 공유 위치입니다.

- 증거 로그: [11-git-config.txt](docs/logs/11-git-config.txt)
- GitHub 로그인 캡처: [git_login.png](docs/screenshots/git_login.png)
- VS Code 연동 캡처: [14-vscode-github-login.png](docs/screenshots/14-vscode-github-login.png)

## 14. 트러블슈팅

### 사례 1. `docker --version`은 되는데 `docker info`가 실패한 문제

- 문제: 터미널에서 `docker --version`은 잘 나왔는데, `docker info`는 실패했습니다.
- 왜 이상한가: `docker --version`은 "도커 명령어 프로그램이 설치되어 있는가"만 확인합니다. 반면 `docker info`는 실제로 컨테이너를 돌리는 엔진이 켜져 있는지까지 확인합니다. 즉 명령어는 있어도, 뒤에서 실제로 일하는 도커 엔진이 꺼져 있으면 `docker info`는 실패할 수 있습니다.
- 원인 추정: OrbStack이 실행되지 않았거나, Docker 엔진이 아직 올라오지 않았다고 판단했습니다.
- 확인 방법: OrbStack 실행 여부를 확인한 뒤 다시 `docker info`를 실행했습니다. 엔진이 꺼져 있을 때는 실패했고, OrbStack을 실행한 뒤에는 정상 출력이 나왔습니다.
- 해결: OrbStack을 먼저 실행한 다음 `docker info`로 다시 점검했습니다.
- 배운 점: Docker는 "명령어 설치"와 "실제 실행 엔진 구동"을 따로 봐야 합니다. 그래서 버전 확인만 하고 끝내면 안 되고, `docker info` 같은 실제 동작 확인이 꼭 필요합니다.

### 사례 2. OrbStack 실행 파일이 `damaged`로 보이던 문제

- 문제: OrbStack을 설치한 뒤 실행하려고 했더니 macOS가 앱이 손상된 것처럼 보이는 경고를 띄웠습니다.
- 왜 이상한가: 다운로드한 앱이 정말 깨졌을 수도 있지만, macOS가 앱을 처음 실행하기 전에 하는 안전 검사에서 막혀도 비슷한 경고가 나올 수 있습니다.
- 원인 추정: 파일 자체가 망가졌다기보다, macOS의 앱 확인 과정이 일시적으로 꼬였을 가능성이 높다고 봤습니다.
- 확인 방법: 재다운로드만으로 해결되지 않았고, 재부팅 후 다시 실행했을 때는 정상적으로 열렸습니다. 이를 보고 파일 손상보다는 시스템 상태 문제라고 판단했습니다.
- 해결: Mac을 재부팅한 뒤 OrbStack을 다시 실행했습니다.
- 배운 점: 앱이 `damaged`로 보인다고 해서 항상 파일이 깨진 것은 아닙니다. 특히 macOS에서는 보안 확인 과정 문제일 수도 있으니, 재부팅이나 실행 상태 점검이 먼저 필요할 수 있습니다.

### 사례 3. 터미널에서 `git` 실행 시 `xcodebuild` 경로 오류가 나던 문제

- 문제: 새 터미널을 열 때마다 `git: unable to locate xcodebuild` 오류가 나왔습니다.
- 왜 이상한가: Git 자체가 없는 것이 아니라, macOS가 개발 도구 위치를 잘못 보고 있어서 Git 실행 중 필요한 도구를 못 찾는 상태였습니다.
- 원인 추정: 시스템이 "개발 도구가 설치된 위치"를 잘못 기억하고 있다고 판단했습니다.
- 확인 방법: `xcode-select -p`로 현재 개발 도구 경로를 확인했고, 올바른 Command Line Tools 경로를 사용할 때는 Git이 정상 동작했습니다.
- 해결: `xcode-select`를 `/Library/Developer/CommandLineTools`로 바꿔 정상 경로를 다시 지정했습니다.
- 배운 점: Git 오류처럼 보여도 실제 원인이 Git 자체가 아닐 수 있습니다. macOS에서는 개발 도구 경로가 틀어져도 Git이 함께 실패할 수 있으므로, 경로 확인이 중요합니다.

## 15. 재현 방법

동일한 결과를 다시 확인하려면 아래 순서대로 진행하시면 됩니다. 모든 명령은 저장소 루트에서 실행하는 것을 기준으로 작성했습니다.

### 15-1. 사전 준비

먼저 OrbStack이 실행 중인지 확인합니다. 저장소가 아직 없다면 클론한 뒤 저장소 루트로 이동합니다. 이미 저장소를 클론해 두었다면 `git clone` 단계는 생략하고 자신의 클론 경로로 이동하시면 됩니다.

```bash
$ git clone https://github.com/zxcv718/cs_1.git
$ cd cs_1
$ docker --version
$ docker info
```

`docker info`가 정상 출력되면 Docker 엔진까지 실행 중인 상태입니다. 경로는 개인 PC마다 다를 수 있으므로, 절대 경로를 그대로 복사하기보다 자신이 클론한 저장소 루트에서 아래 명령을 이어서 실행하는 방식으로 재현하시면 됩니다.

### 15-2. 커스텀 이미지 빌드

[Dockerfile](Dockerfile)을 기준으로 커스텀 이미지를 다시 빌드합니다.

```bash
$ docker build --progress=plain -t codyssey-web:1.0 .
```

빌드가 끝나면 이미지가 생성되었는지 확인합니다.

```bash
$ docker images | rg 'codyssey-web'
```

### 15-3. 포트 매핑 재현

먼저 기존에 같은 이름의 컨테이너가 있다면 정리합니다. 그 다음 8080 포트로 실행합니다.

```bash
$ docker rm -f codyssey-web-8080 2>/dev/null || true
$ docker run -d --name codyssey-web-8080 -p 8080:80 codyssey-web:1.0
$ docker ps --filter name=codyssey-web-8080
$ curl -s http://localhost:8080
```

정상이라면 `Mode: required-assignment`가 포함된 HTML이 출력됩니다. 브라우저에서도 `http://localhost:8080`으로 접속하면 됩니다.

### 15-4. 바인드 마운트 재현

먼저 현재 [site/index.html](site/index.html)이 `after-bind-mount-change` 상태인지 확인합니다. 그 다음 바인드 마운트 컨테이너를 실행합니다.

```bash
$ docker rm -f bind-web 2>/dev/null || true
$ docker run -d --name bind-web -p 8081:80 -v "$(pwd)/site:/usr/share/nginx/html" nginx:1.29.7-alpine
```

이후 변경 전 상태를 만들고 확인합니다.

```bash
$ perl -0pi -e 's/Mode: after-bind-mount-change/Mode: before-bind-mount-change/' site/index.html
$ curl -s http://localhost:8081
```

정상이라면 `Mode: before-bind-mount-change`가 출력됩니다.

이제 다시 변경 후 상태로 되돌리고 확인합니다.

```bash
$ perl -0pi -e 's/Mode: before-bind-mount-change/Mode: after-bind-mount-change/' site/index.html
$ curl -s http://localhost:8081
```

정상이라면 `Mode: after-bind-mount-change`가 출력됩니다. 이 과정으로 호스트 파일 수정이 컨테이너에 즉시 반영되는 것을 확인할 수 있습니다.

### 15-5. 볼륨 영속성 재현

볼륨을 새로 만들고 첫 번째 컨테이너에서 파일을 작성한 뒤, 컨테이너를 삭제하고 두 번째 컨테이너에서 같은 파일이 남아 있는지 확인합니다.

```bash
$ docker rm -f vol-test-evidence vol-test2-evidence 2>/dev/null || true
$ docker volume rm mydata-evidence 2>/dev/null || true
$ docker volume create mydata-evidence
$ docker run -d --name vol-test-evidence -v mydata-evidence:/data ubuntu:24.04 sleep infinity
$ docker exec vol-test-evidence bash -lc "echo hi > /data/hello.txt && cat /data/hello.txt"
$ docker rm -f vol-test-evidence
$ docker run -d --name vol-test2-evidence -v mydata-evidence:/data ubuntu:24.04 sleep infinity
$ docker exec vol-test2-evidence bash -lc "cat /data/hello.txt"
```

두 번 모두 `hi`가 출력되면 볼륨이 컨테이너 삭제 후에도 데이터를 유지한 것입니다.

### 15-6. 결과 확인

실행 결과는 아래 자료와 대조해서 확인하시면 됩니다.

- 로그: [docs/logs](docs/logs)
- 스크린샷: [docs/screenshots](docs/screenshots)
- 웹 소스: [site/index.html](site/index.html)
- 빌드 설정: [Dockerfile](Dockerfile)

### 15-7. 정리 명령

실습이 끝난 뒤 사용한 컨테이너와 볼륨을 정리하려면 아래 명령을 실행하시면 됩니다.

```bash
$ docker rm -f codyssey-web-8080 bind-web codyssey-build-check ubuntu-lab vol-test-evidence vol-test2-evidence 2>/dev/null || true
$ docker volume rm mydata-evidence 2>/dev/null || true
```
