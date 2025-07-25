+++
title = "superfish detection"
date = "2015-02-20"
slug = "2015/02/20/superfish-detection"
Categories = []
+++
Much has been in the press the past couple of days regarding Superfish, specifically being pre-installed on Lenovo hardware, however the issues discussed are relevant to any device with Superfish installed.  It just so happens that Lenovo made the decision to bundle it up in the factory.

There are a number of write-ups on the technical nature of this malware/adware, and I won't attempt to rehash those, they are most likely better than anything that I could contribute anyway.  I did however want to be able to detect this on the network to offer network administrators a chance to locate devices on their network which may be affected.

By creating <a href="https://blog.filippo.io/make-your-own-superfish-infected-vm/">a Superfish infected VM</a> we can examine how the software works in a relatively controlled fashion.<!-- More -->

By using "netstat -ano" both before and after infection it comes obvious that the browsers are redirected to C:\Program Files\Lenovo\VisualDiscovery\VisualDiscovery.exe which listens locally and then makes its own connection to webservers, essentially proxying the connection and resigning SSL connections back to the browser with &quot;<a href="http://blog.erratasec.com/2015/02/extracting-superfish-certificate.html">That Cert</a>&quot;.  This lead me to believe that SuperFish, or more specifically VisualDiscovery.exe, had it's own SSL client code.  As Rob points out in his <a href="http://blog.erratasec.com/2015/02/extracting-superfish-certificate.html">writeup</a> there are proper ways to examine how this works and ghetto ways....  I went ghetto.

We can connect to a collection of HTTPS webservers using Internet Explorer, FireFox and Chrome before infecting the machine, then doing it again after infection and sniff the whole lot.  Next we open up the captures in WireShark and see what's the same, what's different, etc.  I noticed that the browsers favoured TLS1.2 and SuperFish prefers TLS1.1, for example.  However the thing that stood out most was the SuperFish selection of Cipher Suites...

		Cipher Suites Length: 104
		Cipher Suites (52 suites)
		Cipher Suite: TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA (0xc014)
		Cipher Suite: TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA (0xc00a)
		Cipher Suite: TLS_SRP_SHA_DSS_WITH_AES_256_CBC_SHA (0xc022)
		Cipher Suite: TLS_SRP_SHA_RSA_WITH_AES_256_CBC_SHA (0xc021)
		Cipher Suite: TLS_DHE_RSA_WITH_AES_256_CBC_SHA (0x0039)
		Cipher Suite: TLS_DHE_DSS_WITH_AES_256_CBC_SHA (0x0038)
		Cipher Suite: TLS_DHE_RSA_WITH_CAMELLIA_256_CBC_SHA (0x0088)
		Cipher Suite: TLS_DHE_DSS_WITH_CAMELLIA_256_CBC_SHA (0x0087)
		Cipher Suite: TLS_ECDH_RSA_WITH_AES_256_CBC_SHA (0xc00f)
		Cipher Suite: TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA (0xc005)
		Cipher Suite: TLS_RSA_WITH_AES_256_CBC_SHA (0x0035)
		Cipher Suite: TLS_RSA_WITH_CAMELLIA_256_CBC_SHA (0x0084)
		Cipher Suite: TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA (0xc012)
		Cipher Suite: TLS_ECDHE_ECDSA_WITH_3DES_EDE_CBC_SHA (0xc008)
		Cipher Suite: TLS_SRP_SHA_DSS_WITH_3DES_EDE_CBC_SHA (0xc01c)
		Cipher Suite: TLS_SRP_SHA_RSA_WITH_3DES_EDE_CBC_SHA (0xc01b)
		Cipher Suite: TLS_DHE_RSA_WITH_3DES_EDE_CBC_SHA (0x0016)
		Cipher Suite: TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA (0x0013)
		Cipher Suite: TLS_ECDH_RSA_WITH_3DES_EDE_CBC_SHA (0xc00d)
		Cipher Suite: TLS_ECDH_ECDSA_WITH_3DES_EDE_CBC_SHA (0xc003)
		Cipher Suite: TLS_RSA_WITH_3DES_EDE_CBC_SHA (0x000a)
		Cipher Suite: TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA (0xc013)
		Cipher Suite: TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA (0xc009)
		Cipher Suite: TLS_SRP_SHA_DSS_WITH_AES_128_CBC_SHA (0xc01f)
		Cipher Suite: TLS_SRP_SHA_RSA_WITH_AES_128_CBC_SHA (0xc01e)
		Cipher Suite: TLS_DHE_RSA_WITH_AES_128_CBC_SHA (0x0033)
		Cipher Suite: TLS_DHE_DSS_WITH_AES_128_CBC_SHA (0x0032)
		Cipher Suite: TLS_DHE_RSA_WITH_SEED_CBC_SHA (0x009a)
		Cipher Suite: TLS_DHE_DSS_WITH_SEED_CBC_SHA (0x0099)
		Cipher Suite: TLS_DHE_RSA_WITH_CAMELLIA_128_CBC_SHA (0x0045)
		Cipher Suite: TLS_DHE_DSS_WITH_CAMELLIA_128_CBC_SHA (0x0044)
		Cipher Suite: TLS_ECDH_RSA_WITH_AES_128_CBC_SHA (0xc00e)
		Cipher Suite: TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA (0xc004)
		Cipher Suite: TLS_RSA_WITH_AES_128_CBC_SHA (0x002f)
		Cipher Suite: TLS_RSA_WITH_SEED_CBC_SHA (0x0096)
		Cipher Suite: TLS_RSA_WITH_CAMELLIA_128_CBC_SHA (0x0041)
		Cipher Suite: TLS_RSA_WITH_IDEA_CBC_SHA (0x0007)
		Cipher Suite: TLS_ECDHE_RSA_WITH_RC4_128_SHA (0xc011)
		Cipher Suite: TLS_ECDHE_ECDSA_WITH_RC4_128_SHA (0xc007)
		Cipher Suite: TLS_ECDH_RSA_WITH_RC4_128_SHA (0xc00c)
		Cipher Suite: TLS_ECDH_ECDSA_WITH_RC4_128_SHA (0xc002)
		Cipher Suite: TLS_RSA_WITH_RC4_128_SHA (0x0005)
		Cipher Suite: TLS_RSA_WITH_RC4_128_MD5 (0x0004)
		Cipher Suite: TLS_DHE_RSA_WITH_DES_CBC_SHA (0x0015)
		Cipher Suite: TLS_DHE_DSS_WITH_DES_CBC_SHA (0x0012)
		Cipher Suite: TLS_RSA_WITH_DES_CBC_SHA (0x0009)
		Cipher Suite: TLS_DHE_RSA_EXPORT_WITH_DES40_CBC_SHA (0x0014)
		Cipher Suite: TLS_DHE_DSS_EXPORT_WITH_DES40_CBC_SHA (0x0011)
		Cipher Suite: TLS_RSA_EXPORT_WITH_DES40_CBC_SHA (0x0008)
		Cipher Suite: TLS_RSA_EXPORT_WITH_RC2_CBC_40_MD5 (0x0006)
		Cipher Suite: TLS_RSA_EXPORT_WITH_RC4_40_MD5 (0x0003)
		Cipher Suite: TLS_EMPTY_RENEGOTIATION_INFO_SCSV (0x00ff)

So, I have added this as a signature to my <a href="https://github.com/LeeBrotherston/snort/blob/master/snort_interception.rules">snort rules for interception (MiTM) detection</a>.  These rules also include detection for the appliances discovered during my <a href="http://blog.squarelemon.com/blog/2014/10/29/corporation-in-the-middle/">Corporation in The Middle</a> talk, however if you are only interested in SuperFish you want rule sid:1000004.

If anyone has luck, epic failure or anything else I would be really interested in hearing more from you.  I'm <a href="http://twitter.com/synackpse/">@SynAckPse</a> on twitter.

Enjoy!

[Edit: This same technique has allowed me to <a href="http://blog.squarelemon.com/blog/2015/02/23/privdog-detection/">fingerprint PrivDog</a> also.  That fingerprint is included in the <a href="https://github.com/LeeBrotherston/snort/blob/master/snort_interception.rules">snort rules</a>]
