# Day 3 Notes

I decided to try and use Sets to solve this one, which introduced me to
a whole new experience of trying to figure out how to use modules with
minimal documentation. I could see that the `HashSet` had the  `intersect`
function I needed, but it took a long while to figure out how to create
a `HashSet` and what the 2nd type in the signature needed to be.

The problem I was stuck on the longest here was trying to use `chop` on
a string. For whatever reason, this function gave me all sorts of grief
with mismatched Reference Capabilities. The solution in the end was to
`clone()` the variable I wanted to chop, `consume` the clone, and then
things seemed to be fairly happy.

While trying to figure things out, I discovered a new page in the Pony
tutorial that's tucked away in the Appendices -
[A Short Guide to Pony Error Messages](https://tutorial.ponylang.io/appendices/error-messages.html)
which proved to be extremely helpful. Clearly I need to read some more
of the docs I haven't got to yet.

Today was also the first day where my initial answer was wrong, because
I stuffed up the math for uppercase letters.