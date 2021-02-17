#!/bin/bash
set -e

# Launches a new SSH session to specified EC2 host using a new iTerm2 tab with a dynamic profile.

usage_exit() {
  error="$1"

  cat << EOF >&2

ERROR: $error

Usage: ssh-ec2.sh -h <host-query> [-i]
      -h Host name query (instance tag) - can include * for wildcard
      -i Launches SSH command in custom iTerm2 profile

    Examples:
      ./ssh-aws.sh -h instance-name
      ./ssh-ec2.sh -h instance-name -i
      ./ssh-ec2.sh -h "partial-instance-name*"

EOF
  exit 1
}

host_query=""
iTerm=0

while getopts "h:i" flag
do
  case "$flag" in
    h) host_query=$OPTARG;;
    i) iTerm=1;;
    (*) usage_exit "Unknown option"
  esac
done
shift $(($OPTIND - 1))

if [ -z "$host_query" ]
then
  usage_exit "Host name query (-h) is required"
fi

if ! which jq > /dev/null; then
    echo "jq is required"
    exit 1
fi

if ! which aws > /dev/null; then
    echo "aws cli is required"
    exit 1
fi

# TODO: support for instanceId recognition in query and querying on that instead of tag. Could do similar for IP, DNS.

instances=$(aws ec2 describe-instances \
  --query "Reservations[*].Instances[*].{DNS:PublicDnsName,IP:PublicIpAddress,Image:ImageId,Name:Tags[?Key=='Name']|[0].Value}" \
  --filters Name=instance-state-name,Values=running Name=tag:Name,Values="${host_query}" \
  --output=json)

count=$(echo "$instances" | jq '. | length')

if [ "$count" -gt 1 ]; then
    >&2 echo "${count} EC2 matches were found for '$host_query'. Try being more specific."
    exit 1
fi

if [ "$count" -eq 0 ]; then
    >&2 echo "No EC2 matches found for '$host_query'."
    exit 2
fi

instance=$(echo "$instances" | jq '.[][0]')
dns="$(echo $instance | jq -r .DNS)"
ip="$(echo $instance | jq -r .IP)"
name="$(echo $instance | jq -r .Name)"
image="$(echo $instance | jq -r .Image)"

# Might consider a better way to determine OS and default user
ubuntu_image=ami-0dba2cb6798deb6d8
user="ec2-user"

if [ "$ubuntu_image" = "$image" ]; then
  user="ubuntu"
fi

if [ "$iTerm" -eq 1 ]; then
  lib_path="$(osascript -e 'get POSIX path of (path to application support folder from user domain)')"

  # https://iterm2.com/documentation-dynamic-profiles.html
  profile_name=$(echo "$dns" | tr -d '"')
  profile_filename="${lib_path}iTerm2/DynamicProfiles/${profile_name}.json"

  badge_text="${name}"
  tab_title="${name} (${ip})"
  guid=$(uuidgen | tr "[:upper:]" "[:lower:]")

  json=$(sed \
    -e "s/\${BADGE_TEXT}/${badge_text}/" \
    -e "s@\${TAB_TITLE}@${tab_title}@" \
    -e "s@\${GUID}@${guid}@" \
    -e "s@\${NAME}@${name}@" \
    ssh-ec2.json)

  new_file=0
  if [ ! -f "$profile_filename" ]; then
    new_file=1
  fi

  # jq just to format so not all one line, easier to debug. Also to validate.
  echo "$json" | jq '.' > "$profile_filename"

  if [ "$new_file" -eq 1 ]; then
    sleep 0.5
  fi

  applescript_funcs=$(sed -e "s@\${PROFILE}@${name}@" ssh-ec2.applescript)

    osascript <<EOF
${applescript_funcs}
execute("ssh -i $SSH_DEFAULT_KEY ${user}@${dns}", "${name}")
EOF
else
  ssh -i $SSH_DEFAULT_KEY ${user}@${dns}
fi
