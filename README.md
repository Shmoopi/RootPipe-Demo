# RootPipe-Demo

This is a Proof-of-Concept Mac Application that demonstrates the RootPipe Privilege Escalation Vulnerability (CVE-2015-1130) identified by Emil Kvarnhammar from [TrueSec](https://truesecdev.wordpress.com/2015/04/09/hidden-backdoor-api-to-root-privileges-in-apple-os-x/)

This demo was written in Objective-C, ported from the Python PoC here:  [RootPipe](https://github.com/hiburn8/rootpipe)

![Demo Mac Application](RootPipeDemo/Image/RootPipe-Demo.png)

## Usage

To use, simply give a path to a file that you want to have escalated permissions, then provide the path where you want the file to be copied to with the escalated permissions, then provide your permissions in octal format (i.e. 04777), and (optionally) provide the file owner name and group.  

## OS Support

Mac OS X 10.9 - Mac OS X 10.10.2

## License
MIT license. Copyright © 2015 [Shmoopi LLC](http://shmoopi.net/).