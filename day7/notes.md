# Day 7 Notes

This was my first time using `corral` to bring in a dependency that wasn't
in the stdlib - Regex. Fairly straight-forward process and it made working
with and parsing strings a whole heap easier.

Kudos to Shaun for showing me how to use the `as` keyword to get my union
type to behave properly. Not bad for a Rust developer that's never used Pony.

Hit a few more ref cap headaches. Couldn't get an implementation using Iter
to work for me, so I just had to give up and switch back to using a normal
iteration with a for loop. I still don't know where or why `box` was coming
into the mix there, but moved on anyway.

All things considered, the implementation happened pretty easily compared to
previous days.