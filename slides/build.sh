#!/bin/sh
set -e

# Auto-activate the uv-managed venv if present, so ./index.py & friends
# resolve PyYAML / jinja2 from .venv regardless of the caller's environment.
if [ -d "$(dirname "$0")/.venv" ]; then
  VENV_DIR="$(cd "$(dirname "$0")/.venv" && pwd)"
  PATH="$VENV_DIR/bin:$PATH"
  export PATH VIRTUAL_ENV="$VENV_DIR"
fi

case "$1" in
once)
  ./index.py
  for YAML in *.yml; do
    ./markmaker.py $YAML > $YAML.html || {
      rm $YAML.html
      break
    }
  done
  if [ -n "$SLIDECHECKER" ]; then
    for YAML in *.yml; do
      ./appendcheck.py $YAML.html
    done
  fi
  zip -qr slides.zip . && echo "Created slides.zip archive."
  ;;

forever)
  set +e
  # check if entr is installed
  if ! command -v entr >/dev/null; then
    echo >&2 "First install 'entr' with apt, brew, etc."
    exit
  fi

  # If we have a TTY, save/restore terminal state (entr on macOS
  # sometimes leaves the terminal in a bad state on exit).
  # If we don't (running headless / from a wrapper), pass -n to
  # entr so it doesn't try to read from stdin.
  if [ -t 0 ]; then
    ENTR_FLAGS="-d"
    STTY=$(stty -g)
  else
    ENTR_FLAGS="-dn"
    STTY=""
  fi

  while true; do
    find . | entr $ENTR_FLAGS $0 once
    STATUS=$?
    case $STATUS in
    2) echo "Directory has changed. Restarting.";;
    130) echo "SIGINT or q pressed. Exiting."; break;;
    *) echo "Weird exit code: $STATUS. Retrying in 1 second."; sleep 1;;
    esac
  done
  [ -n "$STTY" ] && stty "$STTY"
  ;;

serve)
  PORT="${2:-8000}"
  echo "Serving slides on http://127.0.0.1:$PORT/"
  exec uv run python -m http.server "$PORT" --bind 127.0.0.1
  ;;

*)
  echo "$0 <once|forever|serve [port]>"
  ;;
esac
