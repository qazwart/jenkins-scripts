#! /bin/bash
# description.sh
########################################################################
# CHANGE JENKINS BUILD DESCRIPTION
#
USAGE="
    description.sh [-a|-p] [-u <JenkinsURL>] -j <JenkinsJob> \\
	-b <jenkinsBuild> -d <description> [-c <color>]

	where:
	    -a: Append new description to current description
	    -p: Prepend new description to current description
		Description replaced if neither -p or -a are
		specified.
	    -d: Description for build
	    -u:	Full URL of Jenkins server. If not given, it will be taken
	        from value embedded in program.
	    -j:	Jenkins 'Job' name (aka 'project).
	    -b:	Build Number
	    -c:	Color of text
	    -h: Display this help text
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
prepend_flag=""
append_flag=""
readonly USER="xxxxxxx"
readonly PASSWORD="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

#
# Set options
#
is_extglob_set=$(shopt -q extglob)
[ "$is_extglob_set" ] || shopt -s extglob
while getopts :aphd:u:j:b:c: option
do
    case $option in
	a)  append_flag=1;;
	p)  prepend_flag=1;;
	u)  jenkins_url="$OPTARG";;
	j)  job_name="$OPTARG";;
	b)  build_number="$OPTARG"
	    if [[ "$build_number" != +([0-9]) ]]
	    then
		die "Build number must be numeric"
	    fi
	;;
	c)  color="$OPTARG";;
	d)  new_description="$OPTARG";;
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

[ -z "$new_description" ]   && error "Missing parameter '-d': Description"
[ -z "$build_number" ]	    && error "Missing parameter '-b': Build Number"
[ -z "$job_name" ]	    && error "Missing parameter '-j': Job Name"

#
# Get old description (if -a or -p flag)
#

if [ -n "$append_flag" -o -n "$prepend_flag" ]
then
    old_description=$(curl -s --user "$USER:$PASSWORD" --data "tree=description" \
	"$jenkins_url/job/$job_name/$build_number/api/json")
    if [ $? -ne 0 ]
    then
	echo "Could not retrieve old description of build" 1>&2
	exit 2
    fi
fi
if [ "$old_description" == '{"description":null}' ]
then
    old_description=""
else
    old_description=${old_description#*:\"}	#Remove JSON garbage
    old_description=${old_description%\"\}}	#Remove JSON garbage
fi

#
# Translate linefeeds
#
old_description=$(sed "s/\\r\\n/\r\n/g" <<<$old_description)
if [ $? -ne 0 ]
then
    echo "ERROR: Could not modify the old description with 'sed' command" 1>&2
    exit 2
fi

#
# Create the new description
#
if [ -n "$color" ] #Add color to the description
then
    new_description="<font color=$color><b>$new_description</b></font>"
fi

if [ "$prepend_flag" -a -n "$old_description" ] #Prepend new description to old description
then
    new_description="$(printf "$new_description<br/>\r\n$old_description")"
elif [ "$append_flag" -a -n "$old_description" ] #Append new description to old description
then
    new_description="$(printf "$old_description<br/>\r\n$new_description")"
fi

#
# Now set the description
#

new_description=$(perl url-encode.pl -input "$new_description")
output=$( curl -s -u $USER:$PASSWORD --data "description=$new_description" --data "Submit=Submit" \
    "$jenkins_url/job/$job_name/$build_number/submitDescription" 2>&1)
if [ $? -ne 0 ]
then
    echo "WARNING: Description was not set. Manually change the descripiton of the build" >&2
    echo "         for Build #$build_number in Jenkins job $job_name" >&2
    exit 2
fi

#
# If any "output" is returned by the curl command, it has failed
#
if [ -n "$output" ]
then
    error=$(sed 's/<[^>]*>//g' <<<"$output")
    printf "There was some sort of error:\n%s\n", "$error" >&2
    exit 2
fi

#
# Everything worked out!
#
echo "Description successfully changed on Build #$build_number in Jenkins job $job_name"

#
#
# DONE
########################################################################
