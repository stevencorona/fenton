 npm package that lets you manage your `/etc/hosts` file programmatically on any UNIX based OS (Linux, OS X, FreeBSD). It is similar to [bjeans/ghost](https://github.com/bjeanes/ghost) but does not rely on `dscl` and does not completely take over your hosts file.

# Uses #
Manually managing your hosts file can become a huge pain after you have more than a couple of custom hosts. Additionally, keeping private hosts and ip changes in sync between team members easily becomes a huge hassle.  Fenton makes it easy to add, delete, import, and export your hosts between computers. It doesn't take over your hosts file, so you can still manually manage hosts and it smartly merges changes together so you can sync hosts between people without sharing everything.

## Command Line Interface ##
```
$ sudo fenton --add server.dev 127.0.0.1
   Adding server.dev as 127.0.0.1 to /etc/hosts file...
   { 'server.dev': '127.0.0.1' }

$ sudo fenton --add staging.dev 8.8.8.8
   Adding staging.dev as 8.8.8.8 to /etc/hosts file...
   { 'server.dev': '127.0.0.1',
     'staging.dev': '8.8.8.8' }

# You can modify a host in-place by re-adding it
$ sudo fenton --add staging.dev 8.8.8.9
   Adding staging.dev as 8.8.8.8 to /etc/hosts file...
   { 'server.dev': '127.0.0.1',
     'staging.dev': '8.8.8.9' }

$ sudo fenton --list
   { 'server.dev': '127.0.0.1',
     'staging.dev': '8.8.8.9' }

$ sudo fenton --delete server.dev
   Deleting server.dev from /etc/hosts
   { 'staging.dev': '8.8.8.9' }

# Wildcard matching is supported in the delete method
$ sudo fenton --delete '*.dev'
   Deleting *.dev from /etc/hosts
   { }

# Will export a JSON file with all of the hosts managed by fenton
$ sudo fenton --export fenton.json

# Will import a JSON file- duplicate hosts are skipped, if a host
# already exists but has a different IP, it will modify it to match
# the import file.
$ sudo fenton --import fenton.json
```

# As a Library #
Currently working on de-coupling the library/model for managing the hosts file, but when it is, it should be easy to re-use the host manipulation portion of the code outside of the CLI interface. It is possible to tie fenton in with a git update hook or chef in order to manage hostnames across multiple systems.

# Install #
Not in NPM yet, but when it is..

`sudo npm install fenton`

#### What's in a name? ####

[Man Chasing Dog Chasing Deer](http://abcnews.go.com/blogs/headlines/2011/11/fenton-man-chasing-dog-chasing-deer-unleashes-viral-video-meme/)

You can think of your hostnames as deer- fenton is the dog that herds them into your hosts file.
