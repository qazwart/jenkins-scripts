#! /bin/bash
# description.sh
########################################################################
# CHANGE JENKINS BUILD DESCRIPTION
#
USAGE="
    promotion.sh [-u <JenkinsURL>] -j <JenkinsJob> \\
	-b <jenkinsBuild> -p <promotionName>

    or

    promotion.sh -h

	where:
	    -h: Show this help text.
	    -u:	Full URL of Jenkins server. If not given, it will be taken
	        from value embedded in program.
	    -j:	Jenkins 'Job' name (aka 'project).
	    -b:	Build Number.
	    -p:	Name of the promotion.
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
readonly promotion_url="promotion/promotionProcess"
readonly promotion_plugin_url="promotionCondition/hudson.plugins.promoted_builds.conditions.ManualCondition/approve"

#
# Set options
#
is_extglob_set=$(shopt -q extglob)
[ "$is_extglob_set" ] || shopt -s extglob
while getopts :hu:j:b:p: option
do
    case $option in
	p)  promotion_name="$OPTARG";;
	u)  jenkins_url="$OPTARG";;
	j)  job_name="$OPTARG";;
	b)  build_number="$OPTARG"
	    if [[ $build_number != +([0-9]) ]]
	    then
		error "Build Number must be numeric"
	    fi
	;;
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

[ -z "$promotion_name" ]    && error "Missing parameter '-p': Promotion"
[ -z "$build_number" ]	    && error "Missing parameter '-b': Build Number"
[ -z "$job_name" ]	    && error "Missing parameter '-j': Job Name"

#
# Get old description (if -a or -p flag)
#

#
# Encode Promotion Name
#
encoded_promotion_name=$(perl url-encode.pl -input "$promotion_name");

if [ $? -ne 0 ]
then
    echo "ERROR: Promotion name '$promotion_name' Couldn't be URL encoded" 1>&2
    exit 2
fi

#
# Now do the promotion
#

output=$(curl -s -u "$USER:$PASSWORD" --data "json={}" --data "Submit=Approve" \
    "$jenkins_url/job/$job_name/$build_number/$promotion_url/$encoded_promotion_name/$promotion_plugin_url/")

if [ $? -ne 0 ]
then
    echo "ERROR: Could not execute 'curl' command or could not contact server '$jenkins_url'" 1>&2
    exit 2
fi

#
# If there was any text returned by the curl command, there was an error.
#
if [ -n "$output" ]
then
    error=$(sed 's/<[^>]*>//g' <<<"$output")
    printf "There was some sort of error:\n$error\n" 1>&2
    exit 2
fi

#
# Everything worked out!
#
echo "Build Successfully promoted"

#
# DONE
########################################################################
