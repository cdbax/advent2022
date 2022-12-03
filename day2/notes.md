# Day 2 Notes

This was my first foray into creating some types to represent the
data in a nicer way. I hit some unexpected problems doing this.

Matching on a tuple of primitives caused me problems - the compiler
kept screaming at me about Rock not being a subtype of Paper and Paper
not being a supertype of Scissors and assorted other name-calling and abuse.
To be fair I was calling the compiler all sorts of names too. I didn't find
a nice solution to this, and just gave up and wrote out the 3 cases I needed
to handle.

I'm still no closer to intuiting Reference Capabilities. Getting things
to compile is a crapshoot of adding `recover` blocks and `consume` in places
until things work, not to mention the rabbit hole I went down to start with
of setting the refcap of all the function arguments.

I started this design with trying to have functions on the actors to use like
private methods just to organise things a little more nicely, but the compiler
didn't seem to like that either. To get around it I just pulled the functions
out into primitives with semi-meaningful names.