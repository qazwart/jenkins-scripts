#! /bin/bash
# lock_build.sh
########################################################################
# CHANGE JENKINS BUILD DESCRIPTION
#
USAGE="
    lock_build.sh [-u <JenkinsURL>] -j <JenkinsJob> \\
	-b <jenkinsBuild> ( -L | -U )

    or

    lock_build.sh -h

	where:
	    -h: Show this help text.
	    -u:	Full URL of Jenkins server. If not given, it will be taken
	        from value embedded in program.
	    -j:	Jenkins 'Job' name (aka 'project).
	    -b:	Build Number.
	    -L:	Lock build (Keep build forever)
	    -U: Unlock build (Don't keep it forever)
"
#
########################################################################

########################################################################
# FUNCTIONS
#
function error {
    printf "ERROR: $1\n$USAGE\n" 1>&2
    exit 2
}
#
########################################################################

########################################################################
# MAIN PROGRAM
#

jenkins_url="http://buildl02.tcprod.local/jenkins"
readonly USER="xxxxxxx"
readonly PASSWORD="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

#
# Set options
#
is_extglob_set=$(shopt -q extglob)
[ "$is_extglob_set" ] || shopt -s extglob
while getopts :hu:j:b:LU  option
do
    case $option in
	u)  jenkins_url="$OPTARG";;
	j)  job_name="$OPTARG";;
	b)  build_number="$OPTARG"
	    if [[ $build_number != +([0-9]) ]]
	    then
		error "Build Number must be numeric"
	    fi
	;;
	U)  lock_flag="false";;
	L)  lock_flag="true";;
	h)  printf "\n$USAGE\n"
	    exit 0;;
	*)  error "Invalid Argument";;
    esac
done
shift $(( $OPTIND - 1 ))
[ "$is_extglob_set" ] || shopt -u extglob

#
# Verify options
#

[ -z "$build_number" ]		&& error "Missing parameter '-b': Build Number"
[ -z "$job_name" ]		&& error "Missing parameter '-j': Job Name"
[ -z "$lock_flag" ]		&& error "Missing Lock (-L) or Unlock (-U) parameter"

#
# Get Curreent Lock Status
#

if ! status=$(curl -s -u $USER:$PASSWORD --data "tree=keepLog" \
    "$jenkins_url/job/$job_name/$build_number/api/json")
then
    echo "Cannot get status of current build"
    exit 2
fi

status=${status#*:}
status=${status%\}}

#
# Unlock or lock the build depending upon the flag passed
#

if [ "$lock_flag" != "$status" ]
then
    output=$(curl -s -u $USER:$PASSWORD --data 'json=""' --data "Submit=$lock_flag" \
	"$jenkins_url/job/$job_name/$build_number/toggleLogKeep")
else
    echo "Build lock status already set to '$lock_flag'. No action taken."
    exit 0
fi

#
# Checking status of lock command
#

if [ $? -ne 0 ]
then
    echo "Error in changing Jenkins lock status: Job $job_name build #$build_number (Exit code: $?)" 1>&2
    exit 2
fi
    
if [ -n "$output" ]
then
    error=$(sed 's/<[^>]*>//g' <<<"$output")
    printf "There was some sort of error:\n$error\n" 1>&2
    exit 2
fi

#
# Everything worked out!
#

echo "Lock status successfully changed on the build. Lock Status = $lock_flag"

#
# DONE
########################################################################
