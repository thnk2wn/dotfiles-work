# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export PATH="/Users/ghudik/.dotnet/tools:~/scripts:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="/Users/ghudik/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# https://www.atlassian.com/git/tutorials/dotfiles
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias git-branch-parent='git show-branch | sed "s/].*//" | grep "\*" | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -n1 | sed "s/^.*\[//"'

alias ls='ls -F -G'

## get rid of command not found ##
alias cd..='cd ..'

## a quick way to get out of current directory ##
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'

alias cd-github='cd ~/dev/github'
alias cd-go='cd ~/dev/gocode'
alias cd-hiring='cd ~/dev/gocode/src/hiring'
alias cd-hiring-web='cd ~/dev/gocode/src/hiring/web/jax.jobot.com/www/assets/reactjs'
alias cd-repos='cd ~/repos'

# history - hs keyword
alias hs='history | grep'

alias k=kubectl

# make dir and navigate to
alias mkcd='foo(){ mkdir -p "$1"; cd "$1" }; foo '

# networking
alias myip="curl http://ipecho.net/plain; echo"

alias swagger="docker run --rm -it  --user $(id -u):$(id -g) -e GOPATH=$HOME/go:/go -v $HOME:$HOME -w $(pwd) quay.io/goswagger/swagger"

ec2() {
  host="$1"
  ~/scripts/ssh-ec2.sh -h "$host"
}

ec2tab() {
  host="$1"
  ~/scripts/ssh-ec2.sh -h "$host" -i
}

# ec2cp install-filebeat.sh jax-api-uat
ec2cp() {
  src=$1
  host=$2
  host_path=$3

  if [ -z "$src" ]
  then
    echo >&2 "error: source file to copy is required"
    return 1
  fi

  if [ -z "$host" ]
  then
    echo >&2 "error: host to copy file to is required"
    return 1
  fi

  if [ -z "$host_path" ]
  then
    host_path="~/"
  fi

  scp -i ~/.ssh/jobot-ec2.pem "${src}" "ec2-user@${host}:${host_path}"
}

hugoMod() {
  file="$GOPATH/src/hiring/web/jax.jobot.com/www/layouts/pages/inbox.html"
  contents=$(cat $file)
  echo " $contents" >$file
  sleep .1
  echo -n "$contents" >$file
  stat $file
}

s3open() {
  url="$(echo $1 | xargs)"

  if [ -z "$url" ]
  then
    echo >&2 "error: S3 URL is required"
    return 1
  fi

  file=$(basename $url)
  dest=~/temp
  mkdir -p $dest
  filename="$dest/$file"

  aws s3 cp $url $filename
  result=$?

  if [ $result -ne 0 ]; then
    >&2 echo "AWS s3 copy of '$url' failed with code ${result}"
    exit $result
  fi

  echo "Downloaded to $filename. Opening"
  open $filename
}

s3get() {
  url="$(echo $1 | xargs)"

  if [ -z "$url" ]
  then
    echo >&2 "error: S3 URL is required"
    return 1
  fi

  file=$(basename $url)
  dest=./
  filename="$dest/$file"

  aws s3 cp $url $filename
  result=$?

  if [ $result -ne 0 ]; then
    >&2 echo "AWS s3 copy of '$url' failed with code ${result}"
    exit $result
  fi

  echo "Downloaded to $filename."
  stat $filename
  open $dest
}

s3cat() {
  url="$(echo $1 | xargs)"

  if [ -z "$url" ]
  then
    echo >&2 "error: S3 URL is required"
    return 1
  fi

  aws s3 cp $url - | cat
}

setJaxEnv() {
  env="$1"

  if ! { [[ $env == "uat"  ||  $env == "prod" ||  $env == "local" ]] }; then
    >&2 echo "Environment must must be 'local', 'uat', 'prod' - got '$env'."
    return
  fi

  s3Url="$(
    if [[ "$env" == "uat" ]]; then echo "s3://jobotsecure/jax_profile_uat.sh"
    elif [[ "$env" == "prod" ]]; then echo "s3://jobotsecure/jax_profile.sh"
    else echo ""
    fi
)"

  echo "S3 URL: $s3Url"
  echo "HOME: $HOME"

  profile="$HOME/.zprofile"
  orig="$HOME/OneDrive - Jobot/.profile/.zprofile"
  bak="${profile}.bak"

  if [[ "$env" == "local" ]] then
    cp -f -v $orig $profile
  else
    cp -a -f -v $profile $bak
    aws s3 cp $s3Url $profile

    # overrides
    echo -e "\n" >> $profile
    echo "# OVERRIDES" >> $profile
    echo "export GO111MODULE=off" >> $profile
    echo "export GOPATH=\$HOME/dev/gocode" >> $profile
    echo "export GOROOT=/usr/local/opt/go/libexec" >> $profile
    echo "export PATH=\$PATH:\$GOPATH/bin" >> $profile
  fi

  source $profile
  echo "jax env: $jax_environment"
  code $profile
}

redisHost() {
  local env="$1"
  local host="jobot-jax-uat.e9eze8.ng.0001.use1.cache.amazonaws.com"

  if [ "$env" = "prod" ]; then
    host="jobot-jax.e9eze8.ng.0001.use1.cache.amazonaws.com"
  fi

  echo "$host"
}

redisGet() {
  local key="$1"
  local env="$2"
  local host=$(redisHost $env)
  echo "GET ${key}" | redis-cli -h $host -n 6 | jq
}

redisClientLookup() {
  local key="lookups_$1"
  local env="prod"
  local host=$(redisHost $env)
  local db=1

  local value=$(echo "GET ${key}" | redis-cli -h $host -n $db)

  if [ -z "$value" ]; then
    echo "$key is not set on $host; nothing to reset"
    return
  fi

  local ttl=$(echo "TTL ${key}" | redis-cli -h $host -n $db)

  echo "$key on $host is: $value expires $ttl"
  echo

  if read -q "choice?Reset $key on $host? [y/n] "; then
    echo
    echo "SET ${key} 0 EX $ttl" | redis-cli -h $host -n $db
  else
    echo
    echo "Reset skipped"
  fi
}

ipAdd() {
  local desc="$1"

    if [ -z "$desc" ]
    then
      echo >&2 "error: Description of place is required - i.e. John Doe Starbucks"
      return 1
    fi

  local ip=$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d '"')
  local secGrpName="servers-production-private"
  local host=$(hostname)
  local spec="[{CidrIp=$ip/32,Description=\"${desc} ($host)\"}]"

  AWS_PAGER="" aws ec2 authorize-security-group-ingress \
    --group-name $secGrpName \
    --ip-permissions IpProtocol=all,IpRanges=$spec | jq
}