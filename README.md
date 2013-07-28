# Jenkins Scripts

These are various shell scripts I have written to use for Jenkins remote
operations. These scripts were written with deployments in mind. This
allows you to run promotions, add a build description, and even to lock
the build as required.

## How to use

These scripts are all BASH shell scripts and should run in BASH 3.1 or
higher. There are a few parameters you may want to change in the
scripts:

* `jenkins_url` - This is the URL for your Jenkins build homepage. It is
probably something like `http://jenkins:8080/jenkins` on default
Tomcat or if you're using the internal
[Winstone](http://winstone.sourceforge.net) Servlet Container, or
`http://jenkins/jenkins` if you setup Apache httpd VirtualHost to
redirect to Port 80.
* `USER` - The user to log into Jenkins. This is hard coded for now, but
I may give the option to put this on the command line
* `PASSWORD` - The _password_ for the user. Don't use the actual
password. Instead, look up the Jenkins API token for this user and use
that.

--

NAME
---- 

description.sh

### SYNOPSIS

description.sh -p -j foo-trunk -b 27 -c blue -d "Deploying to $env"

### DESCRIPTION

Used to update a description in a Jenkin build. Builds can contain a
description, and this shell script allows you to remotely set a build's
description by either replacing, appending, or prepending a description
on the build. You can also set the color of the description.

### OPTIONS

* `-u`: Jenkins URL. If not given, will use the one hardcoded in the shell script.
* `-j`: **Required** Jenkins job name.
* `-b`: **Required** Jenkins build number.
* `-d`: **Required** Description to put onto Jenkins build. This will be visible when you look at the build in the Jenkins website, and in the list of builds when you look at the main Jenkins job's page.
* `-a`: Append the description to the current description. The default is to completely replace the description. Cannot be used with the `-p` parameter.
* `-p`: Append the description to the current description. The default is to completely replace the description. Cannot be used with the `-p` parameter.
* `-c`: Color. If given, the font color will be bolded and given this color. Should be an actual HTML color name or color code.
* `-h`: Help. Displays a help page.

--

NAME
----

lock_build.sh

### SYNOPSIS

lock_build.sh -L -j foo-trunk -b 27

### DESCRIPTION

Used to lock or unlock a build. When a build is *locked*, Jenkins won't remove it -- even if the build has officially been aged out according to the Job's configuration. This is useful for builds that are important.

### OPTIONS

* `-h`: Show this help text.
* `-u`: Full URL of Jenkins server. If not given, it will be taken from value embedded in program.
* `-j`: Jenkins 'Job' name (aka 'project).
* `-b`: Build Number.
* `-L`:Lock build (Keep build forever)
* `-U`: Unlock build (Don't keep it forever)

--

Name
----

### SYNOPSIS

    promotion.sh [-u <JenkinsURL>] -j <JenkinsJob> \
	-b <jenkinsBuild> -p <promotionName>

### DESCRIPTION

Used to promote a build via the [Promoted Builds Plugin]
(https://wiki.jenkins-ci.org/display/JENKINS/Promoted+Builds+Plugin).
This script can _press_ the promotion button. This script **cannot**
fill in any information and can only be used in promotion workflows that
contain no parameters.

This plugin is basically used to mark a Jenkins build with the colored
star from the promotion workflow.


###OPTIONS

* `-h`: Show this help text.
* `-u`: Full URL of Jenkins server. If not given, it will be
  taken from value embedded in program.
* `-j`: Jenkins 'Job' name (aka 'project).
* `-b`: Build Number.
* `-p`: Name of the promotion.

--

## NAME

urlencode.pl

### SYNOPSIS

    url-encode -input "my string to URL encode"
    my%20string%20to%20URL%20encode

    url-encode <<<"my string to URL encode"
    my%20string%20to%20URL%20encode

    url-encode "my string to URL encode" | url-encode.pl
    my%20string%20to%20URL%20encode

### DESCRIPTION

This program takes a string and URL encodes it

It returns the string onto STDOUT

### OPTIONS

- \-input

    The string you want to url-encode

- \-help

    Prints help text

- \-documentaion

    Prints out this whole friggin' document

--


## NAME

urlencode.pl

### SYNOPSIS

    url-encode -input "my string to URL encode"
    my%20string%20to%20URL%20encode

    url-encode <<<"my string to URL encode"
    my%20string%20to%20URL%20encode

    url-encode "my string to URL encode" | url-encode.pl
    my%20string%20to%20URL%20encode

### DESCRIPTION

This program takes a string and URL encodes it

It returns the string onto STDOUT

### OPTIONS

- \-input

    The string you want to url-encode

- \-help

    Prints help text

- \-documentaion

    Prints out this whole friggin' document

--

# AUTHOR

David Weintraub [david@weintraub.name](mailto:david@weintraub.name)

# COPYRIGHT

Copyright &copy; 2013 by David Weintraub. All rights reserved. This
program is covered by the open source BMAB license.

The BMAB (Buy me a beer) license allows you to use all code for
whatever reason you want with these three caveats:

1. If you make any modifications in the code, please consider
sending them to me, so I can put them into my code.
1. Give me attribution and credit on this program.
1. If you're in town, buy me a beer. Or, a cup of coffee which is
what I'd prefer. Or, if you're feeling really spend-thrify, you
can buy me lunch. I promise to eat with my mouth closed and to
use a napkin instead of my sleeves.
