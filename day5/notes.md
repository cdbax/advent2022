# Day 5 Notes

Day 5 was the first problem that I managed to get majorly stuck on, mostly because
I continually shot myself in the foot by choosing designs that were not suited to
the problem I was trying to solve.

The problem was inherently one that needed to be completed in series, so of course I
chose to use asynchronous calls to assorted actors, and then have those actors call each
other. This was the path to many headaches and much pain.

Going into this problem I believed causal messaging guarantees would ensure that everything
executed in the correct order. I quickly discovered this was not the case, especially given
I had no control over which actor would process messages first. I had something like:
1. A-cmd->B-put->C-next->A
2. A-cmd->C-put->D-next->A
...which seemed fine, as A will message B and then C, but there's no guarantee that B will
process things first, so C may try to move crates that it doesn't even have yet.

After taking a long time to understand why this was failing, I tried sticking with the same
solution, but added another layer of actors into the mix by introducing promises. Now in
theory promises might be able to actually solve this problem using actors, but I couldn't
figure it out, and decided to go back to square one and abandon actors altogether.

Once I settled on just using a normal class, and solving the problem in a single actor, it
was just back to figuring my way around various reference capability headaches.