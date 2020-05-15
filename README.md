# matlab_checkcode

_Because we all need pointers when it comes to make our codebase better._

A lot of us (at least in neuroscience) learn matlab by aping scripts we have borrowed from someone.
Since the people we take the code from are as likely as you to have taken
'How to write good code 101'<sup>[1](#myfootnote1)</sup>, this is the fastest way to end with
matlab scripts of 1000 lines or above that are a nightmare to debug or to read (for others or for
you in 6 months).

In case you want to avoid this, this function can help you files that are getting too complex or
have too few comments.

## McCabe complexity

A very silly function that will give you the The McCabe complexity of all the m files in a folder.
It will also return the complexity of the subfunctions in each file.

The McCabe complexity of a function is presents how many paths one can take while navigating through
the conditional statements of your function (`if`, `switch`, ...). If it gets above 10 you enter the
danger zone. If you are above 15 you might seriously reconsider
[refactor](https://en.wikipedia.org/wiki/Code_refactoring) your code with sub-functions for example.

-   [refactoring.com](https://refactoring.com/)
-   [refactoring.guru](https://refactoring.guru/refactoring)

### Implementation detail

It relies on the linter used natively by matlab so it will also outputs all the messages relating to
all the little other issues in your code that you have not told matlab to ignore

## Comment your code

This script checks the proportion of lines with comments in each file (might overestimate it).
In general you might want to try to be around 20%.

<a name="myfootnote1">1</a>: i.e very unlikely but don't feel bad those classes are usually not
proposed in most neuroscience departments anyway.


## Automation

If the `check_my_code` function is in the matlab path, you can automate its usage if you use git.

I have created a git hook that will execute the `check_my_code` every time you try to push to your
remote repository. If your code is not up to the standard then the push will be aborted.

To use this here is what you need to do:
1. Copy `pre-push.sample` into your `project/.git/hooks`
2. Copy `pre-push.sample` and rename it to `pre-push`
3. Make this file executable by running `chmod +x .git/hooks/pre-push`
4. Now your code quality will be checked if when you push your code
