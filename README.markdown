Introduction
============

This is a GNOME applet for pidgin.  It will show you the status of your
favorite buddies.  This makes it easy to send offline messages, which will
revolutionize the way you communicate asynchronously.

Configuration
=============
`$HOME/.config/buddyheads/settings`, a YAML file, needs to be created.  At some
point this will be managed by the UI.

Installation
============

Edit the paths in `BuddyHeads_Factory.server` and then put it in `/usr/lib/bonobo/servers`.

Testing
=======

`buddyheads --test` will launch buddyheads in a window instead of as an applet.
