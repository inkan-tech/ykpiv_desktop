# Crypto Architecture Choices

## Introduction

This MD is here for keeping the choices made for architecture on the Crypto side of things. We did try several stuff.

## Elliptic Curve Cryptography

### Curve25519

It's 25519. Is not well supported especially on the browser? But we made it work for you. Twisting the X509 Certificate format to be able to push it. This might be a problem.

### EC384

As our elliptic curves are better supported, we may use EC384 instead, that is more widespread.

## Browser Integration

We try many different approach to use the browser instead, especially for dashboard. We cannot access directly the certificate store the computer. It's a shame, but that's what it is.
We tried many different way to create an extension, but we cannot use a library and an. installing a companion Seems like too much of a burden. But we can maybe Use what we've done here to create certain app and then have an extension. Google restricted access to. access to web usb to. including libraries. and only message. only messages to a companion app running of the computer is allowed. 
### Sharing Wrapped Keys

What we may do is sharing the wrapped keys? Or a sealed kiss of the claims install them with IDB in the browser to be able to see the data but only temporarily and protected by your password. So that the format does not matter that much.

### Phone Integration

We could keep the ecdh secret using a specific action on the phone to use the ECD private key of the same account on the phone. And to shared secret with her password to decrypt only on the browser. Not ideal would prefer using ib ub keys but ubiquitous on their brother requires an extension that might be possible, but we grow a lot of development.
