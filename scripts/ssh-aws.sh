#!/bin/bash
set -e

# Launches a new SSH session to specified EC2 host using a new iTerm2 tab with a dynamic profile.

usage_exit() {
  error="$1"

  cat << EOF >&2

ERROR: $error

Usage: ssh-aws.sh -h <host-name>
      -h Host name (instance tag) - can include * for wildcard

    Examples:
      ./ssh-aws.sh -h instance-name
      ./ssh-aws.sh -h "partial-instance-name*"

EOF
  exit 1
}

host=""
while getopts "h:": flag; do
  case "$flag" in
    h) host=$OPTARG;;
    (*) usage_exit "Unknown option"
  esac
done
shift $(($OPTIND - 1))

if [ -z "$host" ]
then
  usage_exit "Host name (-h) is required"
fi

publicDnsNames=( $(aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].PublicDnsName" \
  --filters Name=instance-state-name,Values=running Name=tag:Name,Values="${host}" \
  --output=text) )

count=${#publicDnsNames[@]}

if (( count > 1 )); then
    >&2 echo "${count} EC2 matches were found for '$host'. Try being more specific."
    exit 1
fi

if (( count == 0 )); then
    >&2 echo "No EC2 matches found for '$host'."
    exit 2
fi

publicDnsName=${publicDnsNames[0]}

lib_path="$(osascript -e 'get POSIX path of (path to application support folder from user domain)')"

# https://iterm2.com/documentation-dynamic-profiles.html
profile_filename="${lib_path}iTerm2/DynamicProfiles/${publicDnsName}.json"

badge_text=$host
tab_title=$host
name=$host
guid=$(uuidgen | tr "[:upper:]" "[:lower:]")
json=$(sed \
  -e "s/\${BADGE_TEXT}/${badge_text}/" \
  -e "s@\${TAB_TITLE}@${tab_title}@" \
  -e "s@\${GUID}@${guid}@" \
  -e "s@\${NAME}@${name}@" \
  ssh-iterm-template.json)

# jq just to format so not all one line, easier to debug. Also to validate.
echo "$json" | jq '.' > "$profile_filename"
#ssh -i $SSH_DEFAULT_KEY ${SSH_DEFAULT_USER}@${publicDnsName}