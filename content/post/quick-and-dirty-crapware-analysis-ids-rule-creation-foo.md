+++
title = "quick and dirty crapware analysis ids rule creation foo"
date = "2015-03-04"
slug = "2015/03/04/quick-and-dirty-crapware-analysis-ids-rule-creation-foo"
Categories = []
+++
Recently I have made some brief posts on the <a href="https://github.com/LeeBrotherston/snort">Snort/Suricata rules</a> that I wrote to detect <a href="http://blog.squarelemon.com/blog/2015/02/20/superfish-detection/">SuperFish</a> and <a href="http://blog.squarelemon.com/blog/2015/02/23/privdog-detection/">PrivDog</a>, two pieces of Crapware/Malware/Adware/PUP that insert themselves as a Certificate Authority in the local browsers and proceed to Man in the Middle HTTPS traffic for the purposes of injecting ads.

In those posts I mentioned that CipherSuite fingerprinting was the key to creating the rules, however I didn't give a very comprehensive technical blow-by-blow.  So, now I have a new rule to add having noticed another application Man in the Middle'ing browsers (<a href="http://geniusbox.net/">GeniusBox</a>) using the same technique, it seems like an apt time to write up what I have been doing in a more useful way.<!-- more -->

Although many of these miscreant applications insert scripts into webpages that are hosted on remote sources, they all conduct their Man in the Middle attacks on the local machine.  The chosen technique is to, either via network hooks or by setting browsers to use localhost as a proxy, ensure that the connection from the browser is terminated locally and a connection to the webserver is made via their "application".  They don't hide this, it is trivial to spot with some ghetto forensics.

First we can use <code>netstat -ano</code> to look at the connections and associated pid's on the local host.  Notice how PID 3388 is making a local connection to a listening PID 4084 on port 49546?  Also note that PID 4084 is also making a number of connections to external hosts on ports 80 (http) and 443 (https):

<img src="/img/netstat.png">

By looking at the details tab on taskmanager we can see which executable names those pids pertain to.  In this case it's iexplore.exe (Internet Explorer) and Client.exe (<a href="http://geniusbox.net/">GeniusBox</a>):

<img src="/img/taskman.png">

Finally, by looking at the process details in Task Manager we can see which directory the binary resides in and can look at that location to see if it really is the app we suspect it is:

<img src="/img/install_dir.png">

Certainly looks that way!

Let's do some CipherSuite fingerprinting and see if we can create a new snort rule.

First we need to sniff the connection, this is easy, I have installed the application in question inside a virtual machine and so can sniff on one of the virtual interfaces using tcpdump/wireshark/t-shark/whatever on my host OS.  I sniff web browsing traffic both before and after I infect the host on as many browsers as I wish to test (in this case Internet Explorer, Firefox and Chrome).  Remember this is SSL so in theory you shouldn't be able to decrypt the traffic and determine what the user agent string is (of course with a MiTM attack if you have the private certs it's entirely possible, as is the case if <a href="https://jimshaver.net/2015/02/11/decrypting-tls-browser-traffic-with-wireshark-the-easy-way/">the browser is configured to save the ssl keys</a>); I would recommend a separate pcap file for each browser both before and after (6 in total in this case) to keep analysis easy.

Each of the captures can be loaded into WireShark in turn for easy analysis (other packet capture tools will show the info too, but WireShark just makes it easy), the hex is helpfully highlighted at the bottom so we know which data to include in a snort/suricata rule:

<img src="/img/wireshark.png" style="border: 1px solid #000000;">

The list is not only the supported Cipher Suites, it is also in preference order.  My research thus far shows the the combination of supported Cipher Suites, preference order and total number of suites offered is fairly unique to each browser family.  It remains static between each connection that the browser makes, this is not a per-session variable.

When looking at <a href="http://blog.squarelemon.com/blog/2015/02/20/superfish-detection/">SuperFish</a> and <a href="http://blog.squarelemon.com/blog/2015/02/23/privdog-detection/">PrivDog</a> I noticed that the 3 browsers all had their own fingerprints prior to infection, but exhibited the same (fourth) fingerprint when intercepted by the applications.  Presumably because the applications terminate SSL locally (resigning it with with their own CA that they installed) and they need to implement a (fourth) SSL client of their own to make the outbound connection to the real webserver, and we can detect that.

Why is this useful?  Network administrators often do not have a handle on exactly what is on their network, BYOD and other initiatives mean that self-prodcured of self-managed devices are prevalent in many environments.  For this reason desktop management systems may not be aware of the presence of these applications, but an IDS/IPS platform can detect them based on network traffic using this technique.  Furthermore, web server administrators can detect on this signature in order to determine if one of their clients (someone browsing to their website) has been affected and potentially warn/block them as desired.  Of course there is always the possibility that someone malicious could detect this for other reasons, but that's a whole other post ;)

We can simply take the hex from WireShark and use that as the "content" for a snort/suricata rule.  Furthermore we can use an offset statement to reduce the chances that we are just picking up the same string of bytes reoccurring in some other context.  The Cipher Suite list in the Client Hello packet is a fixed length from the start of the packet contents.  Using these two details we are able to create a rule:

<code>alert tcp any any -> any 443 (msg:"GeniusBox Cipher Suite Profile Matched"; flow:to_server; reference:url,https://gist.githubusercontent.com/LeeBrotherston/523ffbc02f2407fd213c/raw/008b77bab61d26761119f07d518779ed6edfbd74/sid:1000006; content:"|00 18 c0 14 c0 13 00 35 00 2f c0 0a c0 09 00 38 00 32 00 0a 00 13 00 05 00 04|"; offset: 44; sid:1000006; rev:1;)</code>

(The content also includes the proceeding two bytes which is the ciphersuites length field)

The next phase is to test the rules, but that will be a post of it's own (stay tuned!)

I have added this to <a href="https://github.com/LeeBrotherston/snort">my snort/suricata rules for interception detection</a> which also include coverage for <a href="http://blog.squarelemon.com/blog/2015/02/20/superfish-detection/">SuperFish</a>, <a href="http://blog.squarelemon.com/blog/2015/02/23/privdog-detection/">PrivDog</a> and the techniques described in my <a href="http://blog.squarelemon.com/blog/2014/12/29/bsides-toronto-video-and-slides/">Corporation in the Middle talk</a>.

Any feedback on the rules are greatly appreciated.  Especially if anyone has particular successes to share of failures to highlight that I can use to improve the accuracy.  As always you can <a href="https://twitter.com/synackpse">reach me on twitter, I am @synackpse</a> or <a href="https://github.com/LeeBrotherston/snort/issues">raise an issue in github</a>.
