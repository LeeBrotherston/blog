+++
title = "os x sandbox quickstart"
date = "2015-02-10"
slug = "2015/02/10/os-x-sandbox-quickstart"
Categories = []
+++
The <a href="https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/sandbox-exec.1.html">sandbox feature on OS X</a> is really useful for restricting what applications have access to in more granular and controlled fashion than standard file permissions allow.  However writing the initial sandbox profile can be problematic for many users, it's not always clear what an application needs access to in order to operate in the expected way; there are a number of system files, libraries and such like, that an application quite rightly needs to read.

The news is not all bad, there are some really useful commands built in to OS X which can help.<!-- More -->

Working on the assumption that the threat model that we are protecting against is an application being exploited via a vulnerability or such like (rather than this being a malicious app out of the box), we can run the application without restrictions initially all the while logging which it accesses.  To do this we create a nearly blank sandbox profile which does nothing but log:

		(version 1)
		(trace "/tmp/trace_output.sb")

Next we can run our application via sandbox-exec using this sandbox profile:

		sandbox-exec -f ./trace.sb /Applications/SomeApplication.app/Contents/MacOS/SomeApplication

The application will run slowly, it is after all tracing (logging) every access to a file along with the type of access (read, write, read/write, read metadata, etc) along with other information like accesses to sysctl variables.  This will generate the file /tmp/trace_output.sb which is a working, though huge and inelegant, sandbox profile.  Simply running vim (without even opening a file) will create a 238 line profile (imagine what a browser does).  This can easily be trimmed by sandbox-simplify:

		sandbox-simplify /tmp/trace_output.sb > ./tracesimple.sb

What this essentially does is the sandbox profile equivalent of sort | uniq and then groups the output to be a little easier to read.  This takes the sample vim profile down to 41 lines from the 238 lines it was before.

Let's test if that worked:

		sandbox-exec -f tracesimple.sb /Applications/SomeApplication.app/Contents/MacOS/SomeApplication

The application should now run as expected but have access to nothing outside of what was specified in the sandbox profile.  In the case of the vim example, the code runs as expected but has no permission to open any documents (try opening a file); we have sandboxing \o/

Of course running an application which cannot interact with the filesystem may not be entirely useful, especially for a tool such as vim.  At this point we can begin manually editing the sandbox profile.  We can add additional permissions that we wish to use to ensure that the application can open files that we want it to.  The system has a selection of example profile that you may wish to borrow from in <i>/System/Library/Sandbox/Profiles/</i> alternatively I found <a href="http://reverse.put.as/wp-content/uploads/2011/09/Apple-Sandbox-Guide-v1.0.pdf">this guide</a> really useful.

Of course you may wish to tweak or debug permissions further, this is easy, just add <i>(trace "/tmp/trace_output.sb")</i> to your sandbox profile as we did at the start and you will create a trace file for any additional permissions which may be required.  Enjoy!
