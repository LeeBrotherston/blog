+++
bigimg = ""
date = "2015-09-25T09:00:00-04:00"
subtitle = "Smarter Defending & Stealthier Attacking"
title = "TLS fingerprinting"

+++

## Background

Transport Layer Security (TLS) provides security in the form of encryption to all manner of network connections from legitimate financial transactions, to private conversations, and malware calling home.  The inability for an eavesdropper to analyze this encrypted traffic protects its users, whether they are legitimate or malicious.  Those using TLS operate under the assumption that although an eavesdropper can easily observe the existence of their session, its source and destination IP addresses, that the content itself is secure and unreadable without access to cryptographic keying material at one or both ends of the connection.  On the surface this holds true, barring any configuration flaws or exploitable vulnerabilities.  However, using TLS Fingerprinting, it is easy to quickly and passively determine which client is being used, and then to apply this information from both the attacker and the defender perspectives.

Previously, I have been able to demonstrate that certain clients could be differentiated from other network traffic.  Specifically, that meant discriminating [SuperFish][1], [PrivDog][2], and [GeniusBox][3] from mainstream browsers when making HTTPS connections, and generating [IDS signatures][7] based on these findings to assist network administrators in being able to identify problematic hosts without requiring access to either endpoint.  I have now expanded this technique to improve the accuracy of the fingerprints; provide tools to enable others to create fingerprints; and tools that will enable use by others in their own environments.


## TLS

Prior to entering initiating encrypted communications, TLS needs to create a handshake between the client and server which is then used to select the best mutually acceptable cryptographic ciphers, compression systems, hashing algorithms, etc.  This is conducted in the clear, because the method of cryptography to use has yet to be determined.  This is not problematic from the point of view of breaking cryptography; however, it does allow the opportunity to observe some behavior which is not masked from any eavesdropper by encryption.

A TLS connection will always begin with a Client Hello packet which announces to the server end of the connection the capabilities of the client, presented in preference order.  The server will send back a similar packet, a "server hello" describing the server capabilities in preference order.  By comparing the two packets, the client and server can determine the optimal ciphersuites, compression algorithms, etc. to use per their preferences.


## Fingerprints

By capturing the elements of the Client Hello packet which remain static from session to session for each client, it is possible to build a fingerprint to recognise a particular client on subsequent sessions.  The fields captured are: TLS version, record TLS version, ciphersuites, compression options, and a list of extensions.  Additionally, data is captured from three specific extensions (if available): signature algorithms, elliptic curves and elliptic curve point format.  The use of this combined data is not only reliable in terms of remaining static for any particular client, but offers greater granularity than assessing ciphersuites alone, which has a substantially larger quantity of fingerprint collisions.

Capturing Client Hello packets is a particularly good way of fingerprinting TLS packets for many reasons:

* The Client Hello packet is the first packet in any TLS connection. This allows decisions about subsequent measures, such as active attacks or defenses, to be made at the beginning of the session before protocol spoofing or emulation is required.

* It is possible to capture TLS Client Hello packets with a high degree of accuracy across all ports with absolutely zero requirement to capture both directions of a flow.  This means that sensors in an environment with asymmetric routing, or that suffer from resource constraints potentially causing packets to be dropped, can still collect Client Hello packets whether they have been obscured by running on non-standard ports.

* Client Hello packets occur infrequently enough that it is possible to capture all Client Hello packets on a network for analysis without the substantial investment in storage required for full packet capture.  Taking a random sample of mixed desktop traffic, 4G in each direction, it was possible to store all Client Hello packets using only 20M of disk storage, which could be further reduced to 5.4M of disk if only storing those packets with no session id, i.e. the first packet in any one transaction.

## Collection of Client Hello packets

The collection of Client Hello packets should, if possible, take place without the requirement to track TCP state or, in fact, see any other packet in the same TCP stream.  By doing this, collection can be based on a principle of low "cost", with cost being processing power and memory usage, used to track associated packets to make flow direction determinations, etc, and storage media used to store the packets for processing.

By testing on several gigabytes of test PCAPs, I have found that the following Client Hello Identifiers have low false positives (in my testing, there were in fact zero false positives)  among mixed tcp traffic:

* Byte 0: Value 22, indicating "handshake" per the TLS specification.
* Byte 5: Value 1, indication Client Hello, within a handshake packet, per the TLS specification.
* Byte 9: Value 3, the first byte, of two, of the TLS version which aligns with any version of TLS.  The value could also be 0 if matching SSL.
* Byte 1: As byte 9, except this pertains to the Record TLS version"

These four bytes can be expressed as the following Berkeley Packet Filter:

`tcp[tcp[12]/16*4]=22 and (tcp[tcp[12]/16*4+5]=1) and (tcp[tcp[12]/16*4+9]=3) and (tcp[tcp[12]/16*4+1]=3)`

Additionally, a check for a value of 0 at byte 43, the session length field, will check for only the first Client Hello packet in a TCP stream, still permitting fingerprinting while further reducing required storage space and number of packets processed.

By using this method of filtering out Client Hello packets from other packets on the network, it becomes far more feasible to perform wholesale TLS analysis on an entire network.  Not only are storage and processing is kept to a minimum, but TLS can be detected regardless of the port it is operating on.  This then reduces the effectiveness of obfuscating protocols by running them on alternative ports.

## Tools

In order to make TLS Fingerprinting consumable by the Information Security community I have released a set of open source tools, licensed under the [GNU Public Licence][4], which can be found on the [FingerprinTLS GitHub responsitory][5].  Details of the tools are as  follows.

### FingerprinTLS

[FingerprinTLS][5] is designed to rapidly identify known TLS connections and to fingerprint unknown TLS connections.  Input is taken either via live network sniffing or reading a [PCAP][6] file.  Output for recognized connections is (currently) in human readable form and for unknown fingerprints in the JSON format used for the fingerprint definitions.

Fingerprints which are generated can be exported as a C struct by Fingerprintout and compiled back into FingerprinTLS to enable detecting in future instances.

### Fingerprintout

[Fingerprintout][8] is a tool for managing the fingerprint definitions JSON file with regards to sanitization and export to other formats.  At the time of writing the possible outputs are:

* **struct**: C struct format for people to include the fingerprint definitions in their own code.
* **ids**: output in suricata/snort output for detection on existing IPS/IDS infrastructure.
* **idsinit**: same as ids, but only for the first Client Hello packet per connection.
* **cleanse**: sanitizes JSON file, producing a new JSON file.  This is intended for scrubbing data prior to publishing.
* **xkeyscore**: outputs in regex.  Note, this is not as reliable as other forms because offsets are not as easily defined and so contains the liberal use of `.*` for "some" offset.  DO NOT use this for serious purposes.

## Real World Applications

### Passive detection

The most obvious use of TLS Fingerprinting is for passive detection.  This enables the detection of a wide range of potentially unwanted traffic without requiring access to either endpoint.  The ability to detect malware or software such as SuperFish & PrivDog running on desktops without specifically having to specifically search can be very useful.  Other potentially unwanted software can also be detected using this technique.  For example, the Java updater and TLS connections made by applications written in Java have a specific fingerprint.

The detection of software which may not be malicious, but is out of context, could also be worthy of investigation and is simple to detect.  For example, many interfaces should only be accessed by a particular client or set of clients.  If a web server is expecting human interaction via a browser, detecting the fingerprint of wget could be significant; alternately, an Exchange server may only ever be accessed by Outlook, thus a connection from a Python script would be significant.

### Fingerprint Defined routing

If a connection is either Man in The Middled (MiTM) or Proxied, the decision on where to route that connection can be made on the basis of the TLS Fingerprint.  This is possible because in these situations, a client will perform a TCP handshake with the MiTM tool and send the first packet, the Client Hello, which can be fingerprinted before any other traffic occurs.  The Proxy or MiTM tool can fingerprint the TLS client and make a determination about where to connect onwards to before making a TCP handshake and forwarding the Client Hello packet.

From an attacker's perspective, this facilitates being able to transparently forward connections, unscathed, to their original destination in the event of a client connect that is not vulnerable to attacks, while allowing vulnerable clients to be intercepted and attacked.  Vulnerable clients, however, can be intercepted and attacked.  This allows the attacker avoid those client which could detect malicious activity, display errors, and raise the alarm.  Thus the attacker can remain stealthy, and more likely to remain undetected for a prolonged period of time.

From a defenders perspective, fingerprint defined routing can be used to treat hostile or unknown client types differently from expected clients.  For instance, an unknown client could be forwarded to a minimal, hardened, instance of the service in question, to a honeypot, or to a service which displays an advisory message to the user.

## But.....

### Fingerprint Modification

The natural response for many, of course, is to look at options to modify your TLS fingerprint in order to subvert this technique.  While this is of course possible, there are some complexities which would increase the difficulty.

To modify the fingerprint the Client Hello must be modified, which in turn means choosing to support, and not support, a number of ciphersuites and other features.  In turn this could lower the security of the client or introduce the requirement to support previously unsupported options.  Additionally the fingerprinting technique works not only on the basis of what is offered by the TLS client in a Client Hello packet, but the order in which it does so.  Some libraries and frameworks abstract this level of detail away from the developer adding additional complexity into the process of modifying the fingerprint.

### Fingerprint collisions

As with any fingerprinting technology there is scope for fingerprint collisions, that being where two different applications create the same fingerprint rendering them indistinguishable from each other.  So far in my research collisions have transpired to be caused by applications using a shared codebase or were embedding other technologies, such as webkit, inside the application.  From the perspective of Information Security this is most likely not a collision as these applications will exhibit the same strengths and vulnerabilities as each other.  


## Finally

With an ever growing variety of connections in the enterprise, we will continue to rely on TLS to provide security and privacy via cryptographic means.  Using TLS fingerprinting we can quickly and passively determine which client is being used, and apply strategies from both the attacker and defender perspectives.  These strategies allow us to achieve smarter defending and stealthier attacking.


[1]: http://blog.squarelemon.com/blog/2015/02/20/superfish-detection/
[2]: http://blog.squarelemon.com/blog/2015/02/23/privdog-detection/
[3]: http://blog.squarelemon.com/blog/2015/03/04/quick-and-dirty-crapware-analysis-ids-rule-creation-foo/
[4]: http://www.gnu.org/licenses/
[5]: https://github.com/LeeBrotherston/tls-fingerprinting/tree/master/fingerprintls
[6]: https://en.wikipedia.org/wiki/Pcap
[7]: https://github.com/LeeBrotherston/snort
[8]: https://github.com/LeeBrotherston/tls-fingerprinting/tree/master/scripts/
