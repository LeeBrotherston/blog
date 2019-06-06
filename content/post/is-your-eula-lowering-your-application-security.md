+++
title = "is your eula lowering your application security"
date = "2014-07-18"
slug = "2014/07/18/is-your-eula-lowering-your-application-security"
Categories = []
+++
A couple of days ago I tweeted this:

<center>
<blockquote class="twitter-tweet" lang="en"><p>I&#39;m pretty sure when your EULA prohibits reverse engineering your software, all you prevent is people telling you that they reversed it.</p>&mdash; leE Brotherston (@leEb_public) <a href="https://twitter.com/leEb_public/statuses/489050821649506304">July 15, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
</center>

Quite a lot of people agreed (at the time of writing it has 40 retweets and 19 favourites, which is quite a lot for me), so I thought that I would expand and explain this in a little more detail.<!-- More -->

The End User Licence Agreement (EULA) is something which is fairly common inclusion in commercial applications, and is typically something dreamed up by the legal team to attempt to enforce whatever it is that they feel needs to be added as part of the licencing agreement.  What prompted my particular comment was something I noticed in the EULA of an application I was using, which prohibited the user from being able to:

> "copy, distribute, publish, reverse engineer, decompile, disassemble, modify, or translate the Software"

A <a href="https://duckduckgo.com/?q=%22copy%2C+distribute%2C+publish%2C+reverse+engineer%2C+decompile%2C+disassemble%2C+modify%2C+or+translate+the+Software%22">quick search</a> seems to indicate that this is a fairly common clause in a number of EULAs, particularly in the world of gambling (maybe they all use the same template or legal team).

My assumption is that this clause is included in order to prevent people from creating clone clients, perhaps ones which automate betting and casino style gambling, laundering via robot card games or perhaps just an attempt to hide flaws in the application stack somewhere.

My initial thought was merely that this would not prevent anyone with ill intentions from reversing the code.  People who are willing to use an application or service for fraudulent means are probably committing crimes such as fraud in the process, if they're able to accept that I don't believe that a licence violation will be a massive disincentive.

Similarly if people are not comitting a crime like fraud or money laundering, but are using automated tools to game the system by autmatically playing low-winning games for hours on end, for example, probably don't care about the EULA too much.

Finally, those who are seeking to reverse engineer the code to find exploits and attack the system in some way (ok this is also crime, but a different type) probably will not care about the EULA.

However...

Security researchers, for example, <b>are</b> likely to be dissuaded from taking a closer look at an application by a restrictive EULA, but they are the very people that we do not want to be dissuaded.  We want these people to find the problems and report them responsibly.  In a perfect world you would have a bug bounty program like those at <a href="https://www.etsy.com/ca/help/article/2463">Etsy</a>, <a href="https://www.facebook.com/whitehat">Facebook</a> and <a href="http://technet.microsoft.com/en-us/security/dn425036">Microsoft</a> to incentivize people to disclose bugs early and often.  But even without a formal bug bounty program in place dissuading researchers via the EULA could well lower your security posture.  Chances are that a resrictive EULA has just cut off their only option to report it to you responsibly without fear of some knee-jerk legal retaliation.  Instead, as <a href="https://twitter.com/essobi">@esSOBI</a> rightly points out:

<center>
<blockquote class="twitter-tweet" lang="en"><p><a href="https://twitter.com/leEb_public">@leEb_public</a> <a href="https://twitter.com/thegrugq">@thegrugq</a> &#10;Do you want to wind up on pastebin? Cause that&#39;s how you wind up on pastebin.</p>&mdash; esSOBi (@essobi) <a href="https://twitter.com/essobi/statuses/489109019878248448">July 15, 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
</center>

Perhaps it's time Information Security people engaged with Legal instead of dismissing the EULA on your product as "business stuff" and make sure that it isn't damaging your chances at a more secure product.
