+++
bigimg = ""
date = "2016-08-02T11:17:02-04:00"
subtitle = "Example use cases"
title = "FingerPrintTLS"
+++

#### Introduction

[FingerprinTLS][1] is a tool used to perform [TLS Fingerprinting][2] either via realtime sniffing of an network interface or via reading a PCAP file from the filesystem.

At the time of writing the main features are:

* Detection of:
 * TLS connection irrespective of port numbers or IP addresses
 * Detection within IPv4, IPv6, 6in4, 6rd, and Teredo packets.
 * Detection within 802.1Q packets.
* Logging of events to JSON format log
* Automatic fingerprinting of unknown connections
* Export of unknown fingerprints (JSON format)
* Save client hello packets of unrecognized connections to a separate PCAP.
* Dropping privileges to avoid running as root

This list, however, does not make all the potential use cases immediately evident.  Let's start with the most obvious....

#### Supplementing IDS

Lots of people use an IDS or IPS on their network.  However unless the IDS has access to cryptographic keying material, which in itself is a bad idea, it will be blind to data which is encrypted on the network.  IDS systems do have the ability to alert on issues surrounding the TLS handshakes themselves, such as HeartBleed, however they are typically blind to TLS encrypted data.

So how does [FingerPrinTLS][1] help?  Although it cannot determine the complete unencrypted payload, by being able to identify what the TLS clients responsible for each connection on your network are, there is a lot of useful information which can be derived.

For example:

* *Potential Data Exfiltration Tools*.  Many companies worry about losing data, [FingerPrinTLS][1] can detect connections such as Tor, DropBox, and Google Drive; and differentiate them from other HTTPS traffic.

* *Unauthorized applications*.  If your network is designed to only run specific tools, detection of any other tool is a useful indicator of something beting amiss.

* *Malware* is increasing utilizing TLS to mask it's activities.  Detection of malware communications to command and control infrastructure is a good indicator that something could be infected.  Additionally, because the TLS [Fingerprint][2] is being matched, there is no reliance on blacklists remaining up to date with IP address lists.

So, how we do we detect this?  Using the example that the device `eth1` is connected to a span port, or any other means of recieving sniffed packets for that matter...

`sudo ./fingerprintls -i eth1 -j new_fingerprints.json -l event_log.json -p new_fingerprint_samples.pcap -u unpriv_user`

Will start the packetsniffer and:

* Log all recognised events to the file `event_log.json`
* Dynamically generate fingerprints for unrecognized connections (this is default)
* Log all unrecognised fingerprints to `new_fingerprints.json`
* Keep a sample of unrecognised connections in `new_fingerprint_samples.pcap`
* Drop privileges to run as `unpriv_user`

The event_log.json will produce output with one entry per line in the following format:

`{ "timestamp": "2016-08-01 00:00:00", "event": "fingerprint_match",  "ip_version": "ipv4",  "ipv4_src": "192.168.1.1",  "ipv4_dst": "192.168.255.254", "src_port": 31337, "dst_port": 443, "tls_version": "TLSv1.2", "fingerprint_desc": "Chrome 47", "server_name": "some.host.com" }`

Although it contains all the information in an easy to search and consume format, it's not perfect for tailing and so I have written parselog.py, which tails the log and creates a slightly more human readable format output:

`2016-08-01 00:00:00 "Chrome 47" TLSv1.2 connection to "some.host.com"  192.168.1.1:31337 -> 192.168.255.254 443  (ipv4)`


#### Malware hunting and enhancing ThreatIntel(sorry!) Feeds

Yeah, that makes no sense to me either...  However if you are a fan of threat intelligence and/or hunting out malware on your network then you can use [FingerPrinTLS][1] to supplement and update your feeds.  Let's take this example...

You running as an IDS supplement as described above, and the [FingerPrinTLS][1] does not recognise a connection, and so it dynamically creates a new fingerprint, for the sake of argument "Unknown Fingerprint 3".  However either via antivirus alerts or via a black list or some other mechanism you determine that the connection is some sort of malware calling home.

Even thought [FingerPrinTLS][1] did not have a fingerprint in it's internal database to start with, it does now, it's just not labelled as such.  You can grep through the event_log.json searching for all instances of "Unknown Fingerprint 3" and determine all infected hosts within your network (by source address).  Next you can map out command and control infrastructure by using all the destination addresses, and supplement your ThreatIntelBlackList(tm) with additional IP addresses to be aware of.


#### Protecting API endpoints and Web Servers

For many people Web Servers and API Endpoints need to be exposed to the public internet.  This is, after all, pretty much the point much of the time.  [FingerPrinTLS][1] can be used to determine the validity of connections to those endpoints...

Granted this is not (yet... I'm working on it!) completely automated, however at the very least as a detective control this can work.

By running [FingerPrinTLS][1] in a location where it can monitor internet traffic connecting to your web server or API endpoints you can gather some fairly useful information.  For example if your website starts to receive connections from clients which appear to be BurpSuite, SQLMap, or Metasploit, you may wish to pay attention to what requests are being made from those connections.  Other clients such as curl and wget can be completely innocent, however if they are not expected in the environment then they may also be worthy of scrutiny.


#### Canaries for Unicorns

Let's take an example, you run API endpoint, which is only expected to receive connections to by your own application, examples that spring to mind are: Netflix, Uber, and Slack.  You can run [FingerPrinTLS][1] with a very minimal fingerprint database consisting entirely of the fingerprints for your own application.  If you see a connection from *anything* else, you can investigate.







[1]: https://www.github.com/leebrotherston/tls-fingerprinting/
[2]: https://squarelemon.com/tls-fingerprinting/
