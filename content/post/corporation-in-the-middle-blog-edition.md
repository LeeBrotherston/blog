+++
title = "corporation in the middle blog edition"
date = "2014-11-24"
slug = "2014/11/24/corporation-in-the-middle-blog-edition"
Categories = []
+++
I recently gave a talk entitled <a href="/blog/2014/10/29/corporation-in-the-middle/">Corporation In The Middle</a>.  This post is a summary for the benefit of people who don't want to listen to the recording or try to make sense of my <a href="http://www.slideshare.net/LeeBrotherston/lee-brotherston-corporation-in-the-middle">slides</a> without the commentary.

<h3>Background</h3>
Towards the end of 2013 I noticed that my ISP was inserting banners into webpages to notify me when I consumed 75% or more of my monthly bandwidth allowance.  Nothing suspicious you may think, it is after all a perfectly reasonable message to relay.  However it is not the content of the message which concerns me, it was how they were being injected into the webpage that concerned me.  When I started to work out how the banners were injected I found out that this system is far more troubling than I had at first envisaged.

This post represents a technical(ish) summary of some of the key findings I made whilst investigating.  If you would like a lengthier explanation, then you can listen to the recording from SecTor <a href="http://2014.video.sector.ca/video/110367213">here</a>.  If you would like a more detailed conversation you can find me on <a href="https://twitter.com/synackpse">Twitter</a>.


<h3>Injection Technique</h3>
How are the banners injected?  The first 2 clues present themselves when you see a page which has had a banner injected:<br /><br />
<img src="/img/inject_site.png">
<br />
Note that the URL has not been modified, also note that in addition to the banner, the originally requested content successfully loads below.  Both of these points are important to understanding the technical aspects of how this works, we will come back to them later.
<br /><br />
I wanted to investigate how the banner was being introduced in the first place, the URL would suggest that this is not as simple as an HTTP redirect to another page, this would cause the display of a new URL in the address bar.  Testing this theory was simple, use enough bandwidth that I am due to see some 75% usage warning banners and then connect to my own webserver being sure to packet capture both ends of the connection; one directly on the webserver and another on an ethertap connected to the back of my ISP provided router.<br />
By comparing the two packet captures we can see that following a 3-way TCP handshake the browser sends an HTTP request which never arrives at the webserver, presumably supressed by something in the network.  Immediately a RST/PSH/ACK is sent to the webserver with the packet headers spoofed to appear to come from my client (complete with correct source port, sequence number, etc); this has the effect of closing the connection on the webserver.  Note that a RST is used rather than a FIN, so that the webserver does not send any reply packets which may need to be dealt with.  Finally a HTTP response is sent to the client which is spoofed to appear to be from the webserver (once again with correct port numbers, sequence numbers, etc):<br /><br />
<img src="/img/slide12.png">
<br />
Let me just repeat a couple of key points here:
<ul>
<li>They supressed a valid HTTP packet from me</li>
<li>They spoofed a packet from me</li>
<li>They spoofed a valid response to me</li>
</ul>
As I'm sure you have already guessed, the spoofed HTTP response packet contained the injected banner.  Actually it contained a page with javascript or an iframe (if the browser has javascript disabled), but you get the idea.  This however, is only the beginning of the story.

<h3>TCP Triggering</h3>
Next on my list was to determine how this is triggered at a packet level.  This is really easy, use a host based firewall to drop various types of packets and observe how this changes the injection.  By making several connections blocking each host from sending each portion of the 3-way handshake I noted that at no point did an injection attempt occur, it looks like the TCP session is being tracked and injection only occurs after the HTTP request is sent, which makes sense as we already know whatever device this is knows port numbers, sequence numbers, etc.

<h3>"Interceptability" and Retention</h3>
Remember at the beginning of this post I mentioned that the originally requested content successfully loads under the banner?  Well, let's discuss that.
<br />
I noted that the system being used injects on pages which return the text/html content-type.  It never attempts images, css, xml or anything else that would cause problems.  It's also sensible enough to spot transcations which use HTTP but are not web browsing (such as non-browser apps calling home for updates and such like).  But what does that mean?  That means that the system which is injecting packets has some sort of concept of what is "injectable" and what is not.  The part that concerns me about this is that if you observe a normal HTTP transaction...<br />
<img src="/img/slide22.png"><br />
... you will notice that HTTP response, which includes the content-type occurs at a point <u>after</u> the decision to inject has already been made.  What does this mean?  It means that knowledge of the content type is available prior to the request being made (this cannot be inferred by the file extension on the URL).
<br />
This prompted me to remember something else that I had noticed.  When pages were being injected some pages, pages which I visited regularly would be instantly injected with the banner.  Other times pages which I had not visited would be injected on the second visit, even sites which would appear in any database created by cross-subscriber data (cisco.com, microsoft.com, amazon.com, etc).  This led me to believe that my connection was being monitored and the URLs and their associated content-type was being logged to use when the time comes to inject a webpage.
<br />
The test is simple, setup a web site where any URL rewrites to the same page, allowing me to create infinite unique URLs.  I would visit the webpage multiple times per day (whislt under my 75% bandwidth usage) using a unique URL each time and logging the exact time and date of each.  I would then drive my bandwidth usage to over 75% and revisit each of the URLs in turn, if a URL injected straight away I could assume that it is in the database, if not it would be outside of the database.
<br />
I performed this experiment twice (ok four times, but we'll come back to that) once normally and once with the site being restricted by .htaccess and no public DNS, just an /etc/hosts entry; thus ruling out the possibility of some kind of out of band indexing.
<br />
The result?  Browser history is retained for <b>30 days</b>.  That seems like an awfully long time to retain what is essentially my entire households browser history, just to insert bandwidth usage notifications!
<br />
Going back a step, you notice that I said I did this 4 times.  This is because my original webpage was this:
{% codeblock My HTML Attempt #1 lang:html %}
<html>
<head>
<title>Oh Hai</title>
</head>
{% endcodeblock %}
<br />
Which did not work.  This, however, did:
{% codeblock My HTML Attempt #2 lang:html %}
<!doctype html>
<html>
<head>
<title>Oh Hai</title>
</head>
{% endcodeblock %}
<br />
What does this mean?  It means that not only is the content-type being checked, some unknown portion of the document <b>content</b> is being collected also.  Let's recap again:
<ul><li>Packet supression, spoofing and spoofing</li>
<li>30 day retention of browsing history</li>
<li>Inspection of Content-Type</li>
<li>Inspection of document content</li>
</ul>


<h3>Detection</h3>
With this taking place within the ISP detection can be troublesome, however I have noted a few things which can be used to detect such activities.  Firstly the spoofed HTTP response never has the Do Not Fragment bit set and the TCP window size is explictly set to 1.  This combination is fairly unique, though by no means a guarantee that injection is happening.  If you want to try this out for yourself you can try the following:

tcpdump: <code style="font: courier;">ip[6] = 0 and tcp[14:2] = 1</code><br />
wireshark: <code style="font: courier;">tcp.window_size_value eq 1 and ip.flags.df == 0</code><br />
snort: <code style="font: courier;">alert tcp $EXTERNAL_NET any -> $HOME_NET any (msg:"INJECTION suspected TCP injection"; flow:stateless; window:1; fragbits:!D; sid:31337)</code><br />

I have personally found a 100% success and 0% false positive rate, YMMV of course.<br />
