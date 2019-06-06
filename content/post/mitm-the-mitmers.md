+++
title = "mitm the mitmers"
date = "2015-06-21"
slug = "2015/06/21/mitm-the-mitmers"
Categories = []
+++
Last week I mentioned that <a href="https://www.twitter.com/myrcurial/">James
Arlen</a> and <a href="https://www.twitter.com/synackpse/">I</a> gave the 
<a href="/blog/2015/06/12/sc-congress-toronto/">closing keynote at SCCongress
Toronto</a>.  We had planned to do a live demo as part of the talk, but after
reaching the venue and connecting to the wifi we found that it would not work
as planned, specifically because the venue wifi was "correcting" my tampering
of the DNS on the demo victim, they were still visiting the real website.

And so a new demo was born, the "How this venue wifi is tampering with our, and
your, connection right now" demo.

It appeared that DNS on this network was not used to determine which webserver
to contact when browsing to a page, it was merely a method to ensure that
connections were routed to anything other than the local network, at which
point something else took over.  This is pretty easy to demonstrate, by setting up
an /etc/hosts entry (used to locally override DNS for a particular FQDN) for a
website, directing it to an unused RFC1918 address which was not on the local
network, and by definition not on the internet either, we can test how DNS is
used.  The site still loaded up fine in a browser, this leads me to suspect
that a transparent proxy is inline somewhere, intercepting all traffic and then
using the host header in the HTTP request to determine which pages to deliver
as opposed to using the destination addres in the of the IP header.

Using tcptraceroute on port 80 we also find that every website tested was
apparently located on the local LAN, which of course they are not:

		$ sudo tcptraceroute www.google.com 80
		Selected device en0, address 192.168.1.4, port 55333 for outgoing packets
		Tracing the path to www.google.com (66.185.95.49) on TCP port 80 (http), 30 hops max
		 1  66.185.95.49 [open]  0.576 ms  0.744 ms  0.515 ms

Finally using any packetsniffer (wireshark in this case), we can capture the
payload of a transaction and look for artifacts which may give away what is
happening.  In this instance it was very easy to spot:

{% blockquote %}
X-Cache: MISS from localhost
X-Cache-Lookup: MISS from localhost:3128
Via: 1.1 localhost:3128 (squid/2.7.STABLE9)
{% endblockquote %}

These lines in the HTTP response header are not sent by the webserver, I was
visiting my own webserver, so I'm pretty sure of this fact.  Anyone who has
experience in this field knows that this screams transparent proxy.  And if you
look up the version which is so helpfully displayed, you will notice that it
screams horribly out of date and probably not patched proxy.

The point that we made at the time is that a high percentage of users in the
audience are probably on this network as we spoke, that they were being MiTM'd
without their knowledge.  If someone had compromised that old version of squid
that they could have been doing any number of things to those http connections
and the devices using them.

As security professionals we talk about the dangers of conference and coffee
shop wifi all the time, from the point of view of other users of the network
being malicious.  It's always worth remembering that you can't trust the venues
themselves to be completely clean either.
