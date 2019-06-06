+++
title = "mitm at 30,000 feet"
date = "2015-01-04"
slug = "2015/01/04/mitm-at-30"
Categories = []
+++
In the past week I have seen a few mentions on twitter regarding <a href="http://twitter.com/gogo">Gogo Air</a> presenting fake SSL certs for YouTube to users of their in air Internet access service:<br /><!-- More -->

<blockquote class="twitter-tweet" lang="en"><p>hey <a href="https://twitter.com/Gogo">@Gogo</a>, why are you issuing *.google.com certificates on your planes? <a href="http://t.co/UmpIQ2pDaU">pic.twitter.com/UmpIQ2pDaU</a></p>&mdash; Adrienne Porter Felt (@__apf__) <a href="https://twitter.com/__apf__/status/551083956326920192">January 2, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<br />

<blockquote class="twitter-tweet" lang="en"><p>No, not OK. <a href="https://twitter.com/Gogo">@Gogo</a> please justify breaking the Internet for your paying users. Huge privacy connotations! <a href="http://t.co/AxZOPEK0oO">pic.twitter.com/AxZOPEK0oO</a></p>&mdash; Ben Hughes (@benjammingh) <a href="https://twitter.com/benjammingh/status/551589274123247616">January 4, 2015</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<br />

I started to wonder if they were using the same technique that I had recently been researching and discussing in my <a href="http://blog.squarelemon.com/blog/2014/10/29/corporation-in-the-middle/">Corporation in The Middle</a> talk.  Luckily for me, my friend <a href="https://twitter.com/benjammingh/">Benjammingh</a> was one of those who noticed and was currently on a Gogo flight, so I asked him to take a packetdump for analysis.<br /><br /><!-- More -->

The short summary is that this is not the same technique, in fact this looks like in-flight transparent proxying....<br /><br />

For one thing there is this giveaway in the http response header:<br />

		X-Cache: MISS from 172.19.134.2
		X-Cache-Lookup: MISS from 172.19.134.2:3128
		Via: 1.0 172.19.134.2:3128 (squid/2.6.STABLE14)

<br />
This is indeed squid, quite an old install of squid, on the default port.<br /><br />

Secondly, the TTL on all the packets was 64.  Now, most OS's tend to use round numbers for default TTL values (32, 64, 128).  Assuming this to be the case, this would indicate that either YouTube is exactly 64 hops away or the packets are originating from the local network segment, which would be consistent with a local (transparent) proxy.
<br />
It's hardly an in-depth analysis, but at this point it seems to be more than we have at the minute, and it would explain how they are Man in The Middle'ing the connection, the question still remains.... why?
