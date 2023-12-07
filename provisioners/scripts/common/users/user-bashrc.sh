# @(#).bashrc       1.0 2023/12/06 SMI
# bash resource configuration for cnao lpad users.

# source global definitions.
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# user specific aliases and functions.
umask 022

# set java home path.
JAVA_HOME=/usr/local/java/jdk180
#JAVA_HOME=/usr/local/java/jdk11
#JAVA_HOME=/usr/local/java/jdk17
#JAVA_HOME=/usr/local/java/jdk21
export JAVA_HOME

# set ant home path.
ANT_HOME=/usr/local/apache/apache-ant
export ANT_HOME

# set maven home environment variables.
M2_HOME=/usr/local/apache/apache-maven
export M2_HOME
M2_REPO=$HOME/.m2
export M2_REPO
MAVEN_OPTS=-Dfile.encoding="UTF-8"
export MAVEN_OPTS
M2=$M2_HOME/bin
export M2

# set groovy home environment variables.
GROOVY_HOME=/usr/local/apache/groovy
export GROOVY_HOME

# set gradle home path.
GRADLE_HOME=/usr/local/gradle/gradle
export GRADLE_HOME

# set git home paths.
GIT_HOME=/usr/local/git/git
export GIT_HOME
GIT_FLOW_HOME=/usr/local/git/gitflow
export GIT_FLOW_HOME

# set go home paths.
GOROOT=/usr/local/google/go
export GOROOT
GOPATH=$HOME/go
export GOPATH

# set devops home path.
devops_home=/opt/cnao-lab-devops
export devops_home

# set kubectl config path.
KUBECONFIG=$HOME/.kube/config
export KUBECONFIG

# set cnao lab environment variables.
aws_region_name="us-east-2"
export aws_region_name

aws_eks_cluster_name="CNAO-Lab-01-abcde-EKS"
export aws_eks_cluster_name

eks_kubeconfig_filepath="$HOME/.kube/config"
export eks_kubeconfig_filepath

cnao_k8s_apm_name="cnao-lab-01-abcde-eks"
export cnao_k8s_apm_name

cnao_lab_id="cnao-lab-01-abcde"
export cnao_lab_id

cnao_lab_number="01"
export cnao_lab_number

# define prompt code and colors.
reset='\[\e]0;\w\a\]'

black='\[\e[30m\]'
red='\[\e[31m\]'
green='\[\e[32m\]'
yellow='\[\e[33m\]'
blue='\[\e[34m\]'
magenta='\[\e[35m\]'
cyan='\[\e[36m\]'
white='\[\e[0m\]'

# define command line prompt.
#PS1="\h[\u] \$ "
#PS1="$(uname -n)[$(whoami)] $ "
#PS1="${reset}${blue}\h${magenta}[${cyan}\u${magenta}]${white}\$ "
PS1="${reset}${cyan}\h${blue}[${green}\u${blue}]${white}\$ "
export PS1

# add local applications to main PATH.
PATH=$JAVA_HOME/bin:$ANT_HOME/bin:$M2:${GROOVY_HOME}/bin:$GRADLE_HOME/bin:$GIT_HOME/bin:$GIT_FLOW_HOME/bin:$GOROOT/bin:$GOPATH/bin:$HOME/.local/bin:$PATH
export PATH

# set options.
set -o noclobber
set -o ignoreeof
set -o vi

# set environment variables to configure command history.
HISTSIZE=16384
export HISTSIZE
HISTCONTROL=ignoredups
export HISTCONTROL

# define system alias commands.
alias back='cd $OLDPWD; pwd'
alias c=clear
alias devopshome='cd $devops_home; pwd'
alias here='cd $here; pwd'
alias more='less'
alias there='cd $there; pwd'
alias vi='vim'

# fix issue with bash shell tab completion.
complete -r

# process bash completion files.
bcfiles=( .docker-completion.sh .git-completion.bash )

for bcfile in ${bcfiles[@]}; do
  # source bash completion file.
  if [ -f $HOME/${bcfile} ]; then
    . $HOME/${bcfile}
  fi
done

function lsf {
  echo ""
  pwd
  echo ""
  ls -alF $@
  echo ""
}

function psgrep {
  ps -ef | grep "UID\|$@" | grep -v grep
}

function netstatgrep {
  netstat -ant | grep "Active\|Proto\|$@"
}

function otel_demo_urls {
  echo ""
  echo "------------------------------------------------------------------------------------------------------------------------"
  echo "OpenTelemetry Demo Application URLs"
  echo "------------------------------------------------------------------------------------------------------------------------"
  echo "  The following services will be available once the Load Balancer has completed its Health checks:"
  echo ""
  kubectl get services -n $cnao_lab_id ${cnao_lab_id}-otel-demo-frontendproxy | awk '/frontendproxy/ {printf "    Webstore:          http://%s:%s/\n", $4, substr($5,0,index($5,":")-1)}'
  kubectl get services -n $cnao_lab_id ${cnao_lab_id}-otel-demo-frontendproxy | awk '/frontendproxy/ {printf "    Grafana:           http://%s:%s/grafana/\n", $4, substr($5,0,index($5,":")-1)}'
  kubectl get services -n $cnao_lab_id ${cnao_lab_id}-otel-demo-frontendproxy | awk '/frontendproxy/ {printf "    Feature Flags UI:  http://%s:%s/feature/\n", $4, substr($5,0,index($5,":")-1)}'
  kubectl get services -n $cnao_lab_id ${cnao_lab_id}-otel-demo-frontendproxy | awk '/frontendproxy/ {printf "    Load Generator UI: http://%s:%s/loadgen/\n", $4, substr($5,0,index($5,":")-1)}'
  kubectl get services -n $cnao_lab_id ${cnao_lab_id}-otel-demo-frontendproxy | awk '/frontendproxy/ {printf "    Jaeger UI:         http://%s:%s/jaeger/ui/\n", $4, substr($5,0,index($5,":")-1)}'
  echo "------------------------------------------------------------------------------------------------------------------------"
  echo ""
}
