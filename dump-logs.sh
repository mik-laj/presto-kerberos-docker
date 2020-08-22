function run_color() {
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
  echo -e "${BLUE}[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*${NC}" >&2
  eval "$*"
}

run_color docker ps
run_color find . | grep -v "^./.git"
run_color docker container ls
run_color docker container ls --format '{{.ID}}' | xargs -t -n 1 docker logs