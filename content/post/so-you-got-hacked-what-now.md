+++
title = "So you got hacked, what now?"
date = "2019-06-19T22:46:09-0400"
bigimg = ""
+++

If you have just found out that one of your accounts has been hacked, you
probably have a lot of questions.  One of which is how to you undo whatever has
been done and regain control.  This is a good first question and I will attempt
to cover this and the accompanying "how did this happen?".  The why and the who
part can be more nuanced and very contextual so I'm going to steer away from
that for now.

## First things first

If you're working through these steps you presumably already know that
something has happened.  Maybe you've been locked out of your email or a social
media account, perhaps friends and family have receieved messages that weren't
from you, or there has been some strange activity on one of your accounts.
That's a good first step, you know that something is wrong, however if we wade
directly into fixing things before we fully understand what is wrong we may be
unsuccessful in keeping the attacker out and may have to do the work over, so
let's take a moment to think.

Peicing together what happened, in what order, even if you don't fully
understand it, can be useful.  Think about if anything strange has happened
that you dismissed as inconsequential at the time, but given this context could
be related?  Has your computer acted unusually, have messages appeared or
disappeared in your email, did you maybe fall for a phishing email that you
didn't clue into at the time?  Think if you opened any unusual documents or
attachments, or connected any new devices.

We think about this because although someone could jump directly to attacking,
say, a social media account, it is also possible that they attacked your email
account, to be able to perform a password reset on your social media account.
If we focussed on that social media account and don't consider the email
account then they could simply reset the password again, and again.  For this
reason the timeline helps us to figure out where to look.

In the most generalized terms this is the order you want to fix things:

- *Your computer*.  If it has a virus, malware, keylogger, etc.  Then fixing
  anything else is moot.  As someone could just use their access to your laptop
  to watch you typing the new passwords to things.

- *Your email account*.  Email is the modern day keys to the kingdom.  If you do
  not have 2-factor authentication enabled, most accounts can be accessed via
  requesting a password reset link to an email address.

- *Accounts used for logins elsewhere*.  Many sites social logins, i.e. "Login
  with Facebook", or "Log in with Google".  If your account at one of these
  identity providers is compromised, then they would be able to access everything
  that you use this account to access. 

- *General use accounts*.  Finally we get to your general use accounts, social
  media, cloud storage, etc.

We use this order because any step in this list can be negated by the previous
step.


## Your Computer

Fixing an infection on a computer is a very broad and complex subject.

Ensure that you have copies of all your data.  This is general good practice,
but doubly so when dealing with this sort of situation.  When you are sure that
you have all the important data, you can proceed.

At the simplest end of things, ensure that your antivirus is up to date, and
run a full system scan.  If we are lucky this will catch and fix the problem.

Antivirus is far from perfect and foolproof, however, and so it may not fix the
issue.  If you have date that you believe issues started happening, check
through your files, browser history, email messages, etc to see if there is
something that you could have inadvertently opened in order to cause this.
Consider any software that you may have downloaded around that time,
incase that has been used to introduce malware to your system.

I you believe that your computer is the root cause of this issue, but cannot
find a potential cause, then disconnecting it from any networks and using a
clean computer to fix your accounts is a sensible path until such time as you
are able to fix that it.

If the computer is compromised, you need to assume that the documents which it
has access to, things that have been typed on the keyboard, etc are known to
the attacker at this point.  If this is information which could potentially
cause harm to you, you should take steps to mitigate that risk.


## Your email account

There are many ways that people gain access to email accounts.  If they have
infected your computer with malware, then they may simply watch what you type.
However what is more common are attacks around poor password practices.  If you
use the same password on multiple websites, when another website (where you use
the same password) is breached, attackers will take the stolen usernames and
passwords and try them on other websites in the hope that they have been
reused.  Similarly if you use a simple to guess password, then attacks where
many passwords per account are attempted (such as brute force and dictionary
attacks) may yield results.

So change your email password to something unique, and complex.

Enable 2-factor authentication, so that even if someone obtains your password,
there is another hurdle in the way of them gaining access to your account.

Check that they have not changed your settings to enable them to persist
access.  For example setting up email forwarding rules to another email
address, or a secondary set of passwords via "application passwords" or such
like.  If they have done so, they no longer need the password as they will
already have another route to read your email.

Ensure that the reset email address has not been changed to something in the
attackers control.

If available, review the login history of this account.  This should give you a
good idea as to when the problem started.  Do not place too much value in the
where logins occured from, as the location of an attack is trivial for an
attacker to hide.

As painful as it may be, you have to work on the assumption that whomever
gained access to your email account, has read, or taken copies of, those
emails.  If there is information in there which could be used to otherwise
attack you, you should take steps to mitigate those risks.  Consider not only
information such as passwords, but medical and financial information,
information which could be used to impersonate you, potential contacts to
socially engineer, etc.


## Accounts use for logins elsewhere

Although this is it's own section, the advice is the same as your email
account.  This exists only to keep the order of events clear.  This is because,
if this cleaned up before your email, it is likely that a compromised email
address could be used to regain access.


## General use accounts

Of course each provider has their own capabilities, and so the advice here is
largely generic.  However the general steps are:

- *Check that 2FA has not been setup on someone elses SMS number*.  Ideally, of
  course, you are not using SMS for 2FA, but are using another method, however
  we do not always have the decision.  If an attacker gains access to an account
  with 2FA, they may change that to something that they have access to to lock
  you out and keep them in.  If this is the case, also change this back to
  something within your control.

- *Check the reset email address* has not been changed to something else, or a
  secondary reset email address added.  These are methods that an attacker
  could use to regain access.

- Now that your credentials are reset *review the login history*, and look for
  logins that are obviously not you.  As mentioned before, do not place too
  much value in the where logins occured from, as the location of an attack is
  trivial for an attacker to hide.  However by looking at the times that an
  attacker logged in, you can formulate a good idea of what information they may
  have seen, or been looking for.

- *Check for actions they have taken as you*, for example messages they have
  sent using your account, personal details that they have changed, etc.



# Finally

There are some more things that I would recommend that you do once you have finished the technical part of your cleanup:

- Contact the appropriate people in your contact list, and explain the
  compromise to the degree that you are able.  This is mostly to ensure that
  someone cannot use the information that they gleaned from your accounts to
  impersonate you or otherwise use social engineering techniques against your
  contacts or others that have been exposed whilst they had access to your
  information.

- Place a freeze on your credit.  This prevents people from applying for credit
  in your name using the information gleaned during their access to your
  accounts or computers.

- Tell your cellphone company if you believe that they may try to access your
  account, attempt to port out your number, etc.  Some companies can place a
  password on the account to prevent transfers or at the very least a note on
  your account to say that they should be cautious about such requests.
