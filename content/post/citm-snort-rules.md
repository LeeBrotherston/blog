+++
title = "citm snort rules"
date = "2015-01-27"
slug = "2015/01/27/citm-snort-rules"
Categories = []
+++
Last year I gave my Corporation In The Middle talk in which I explained how my ISP has been man-in-the-middle'ing my connection to inject a warning banner into the top of webpages I visited (talk content <a href="blog.squarelemon.com/blog/2014/10/29/corporation-in-the-middle/">here</a> and <a href="http://blog.squarelemon.com/blog/2014/12/29/bsides-toronto-video-and-slides/">here</a>).

Part of this involved traffic analysis to discover artifacts of the injection process.  In an effort to make this process more automated, repeatable and accessible I have put together a few snort rules to allow others to alert on this condition:<br />

<a href="https://github.com/LeeBrotherston/snort">https://github.com/LeeBrotherston/snort</a><br />

One rule is commented out as it is noisy and prone to false positives, however I have included it (disabled) for now, for reference.  The other three rules have been tested by me on my personal environment and seem to be free from false positives, however this is only a limited test and so feedback would be really appreciated from anyone running them elsewhere.<br />

Of course these are far from complete in terms of detection of man in the middle generically, they only pertain to the specific technique outlined in my talk, however I will endeavour to update them as I obtain further information.
