#!/usr/bin/env bash

name=$(git config user.name)
since=""
until=""

help() {
    echo "Usage: git-activity.sh [OPTIONS]"
    echo "Show git activity of a user."
    echo "Options:" 
    echo "  -s, --since     Show git activity since a specific date. (format - 'YYYY-MM-DD')"
    echo "  -u, --until     Show git activity until a specific date. (format - 'YYYY-MM-DD')"
    echo "  -n, --name  Show git activity of a specific user. (default - git config user.name)"
    echo "                  In case of 2 or more words, pass it as last argument without quotes."
    echo "  -h, --help      Show this help message and exit." 
    echo -e "\n Example: git-activity.sh -s 2021-01-01  -u John Doe" 
}

get_stats() {
    local name=$1
    local since=$2
    local until=$3
    git log ${since:+--since="$since"} ${until:+--until="$until"} --shortstat --author="$name" | grep -E "fil(e|es) changed" | awk '{files+=$1; inserted+=$4; deleted+=$6; delta+=$4-$6; ratio=deleted/inserted} END {printf "- Files changed (total)...  %s\n- Lines added (total).....  %s\n- Lines deleted (total)...  %s\n- Total lines (delta).....  %s\n- Add./Del. ratio (1:n)...  1 : %s\n", files, inserted, deleted, delta, ratio }' -
}

get_commits() {
    local name=$1
    local since=$2
    local until=$3
    git shortlog ${since:+--since="$since"} ${until:+--until="$until"} -sn --no-merges  --author="$name" | awk '{print "- Total commits (no merge). " $1}'
}

while (( "$#" )); do
  case "$1" in
    -s|--since)
      if [[ "$2" ]]; then
        since="$2"
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -u|--until)
      if [[ "$2" ]]; then
        until="$2"
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -n|--name)
      if [[ "$2" ]]; then
        name="$2"
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -h|--help)
      help
      exit 0
      ;;
    --) # end argument parsing
      shift 
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1 \n" >&2
      help
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

stats=$(get_stats "$name" "$since" "$until")
commits=$(get_commits "$name" "$since" "$until")

echo -e "Git activity: \n\n$name \n$stats \n$commits" 