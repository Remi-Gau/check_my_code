# check_my_code

_Because we all need pointers when it comes to make our codebase better._

A lot of us (at least in neuroscience) learn matlab by aping scripts we have borrowed from someone:
one day you were given some .m files, a tap on the shoulder and "good luck" and you have been reverse
engineering the wheel on what it means to write good code since then.

One of the reason for this is that people, whose code we are learning from, are as likely as you to have taken
'How to write good code 101' (i.e very unlikely but don't feel bad those classes are usually not
proposed in most neuroscience departments anyway).

All of this is the fastest way to end with a codebase of matlab scripts of 1000 lines or above that
that have more loose ends than a bowl of spaghetti and are a nightmare to debug or to read
(for others or for you in 6 months).

In case you want to avoid this, this function can help you by pointing the files that are getting
too complex or have too few comments.

<!-- TOC -->

- [matlab_checkcode](#matlab_checkcode)
  - [McCabe complexity](#mccabe-complexity)
  - [check_my_code](#check_my_code)
    - [INPUTS](#inputs)
      - [recursive](#recursive)
      - [cplx_thrs](#cplx_thrs)
      - [comment_thres](#comment_thres)
      - [print_file](#print_file)
    - [OUPUTS](#ouputs)
      - [error_code](#error_code)
      - [file_function](#file_function)
      - [cplx : 1 X 2 ARRAY](#cplx--1-x-2-array)
      - [percentage_comment](#percentage_comment)
  - [Installation](#installation)
    - [Requirements](#requirements)
    - [Direct download](#direct-download)
    - [Git](#git)
    - [matlab package manager](#matlab-package-manager)
  - [Implementation detail](#implementation-detail)
  - [Automation](#automation)

<!-- /TOC -->

## McCabe complexity

The McCabe complexity of a function is presents how many paths one can take while navigating through
the conditional statements of your function (`if`, `switch`, ...). If it gets above 10 you enter the
danger zone. If you are above 15 you want to seriously consider
[refactoring](https://en.wikipedia.org/wiki/Code_refactoring) your code with sub-functions for example.

-   [refactoring.com](https://refactoring.com/)
-   [refactoring.guru](https://refactoring.guru/refactoring)

## check_my_code

It is function that will give you the The McCabe complexity of all the `.m` files in the current directory.
It will also return the complexity of the sub-functions in each file.

This function checks the proportion of lines with comments in each file (might overestimate it).
In general you might want to try to be around 20%.

It will then list the functions that do not meet the requirements you have set for your projects.
You can then use this information to figure out which function you should refactor first.

The idea for this is partly inspired by this "equivalent" in [python](https://github.com/PyCQA/mccabe)

### INPUTS

#### recursive

BOOLEAN: if set to true this will check the `.m` files in all the sub-folders. (default: false)

#### cplx_thrs

1 X 2 ARRAY: Thresholds for the acceptable McCabe complexity before triggering a warning.
Having 2 values lets you decide a zone of complexity that is high but acceptable and another that is
too high. (default: `[15 20]`)

#### comment_thres

1 X 2 ARRAY : thresholds for the acceptable percentage of comments in a file
    before triggering a warning.
    Having 2 values lets you decide levels that are low but acceptable and another that is
    too low. (default: `[20 10]`)

#### print_file

BOOLEAN this will print a file with the overall error code ; mostly used for automation
    for now. (default: true)

### OUPUTS

#### error_code
an array wth `[cplx_error_code comment_error_code]` where each value is 0 if there is no file that
is too complex or has too few comments and is 1 otherwise

#### file_function
a n X 2 cell listing of all the function in {i,1} and subfunction in {i,2} tested. If the function is
the main function of a file then {i,1} and {i,2} are the same.

#### cplx
an array with the complexity of each function and subfunction

#### percentage_comment
an array with the percentage of comment in each file

## Installation

### Requirements

Some aspects of this function will require Matlab 2017a (recursive search through sub-folders) or above to work.

Also because octave does not have a linter, so this will only work with matlab.

Any help is welcome to make this available to older Matlab version or to implement it in octave.

### Direct download

Click on the `Clone or download` button and then on `Download ZIP`. Unzip the downloaded file and add the content of the zipped folder to your matlab path.

### Git

If you use Git you can get this repository by typing this in a terminal:

```
git clone https://github.com/Remi-Gau/matlab_checkcode.git

```

Otherwise you could fork this repository onto your github account by clikcing the `fork` on the top right of the screen and then clone that copy onto your computer by typing.

```
git clone https://github.com/YOUR_GITHUB_USERNAME/matlab_checkcode.git

```

In either case you will then need to add the newly created folder to your matlab path.

### matlab package manager

If you use the [matlab package manager](https://github.com/mobeets/mpm), to simply download
this repository by typing this in the matlab prompt:

```
mpm install matlab_checkcode -u https://github.com/Remi-Gau/matlab_checkcode.git
```

This will add `check_my_code` to the matlab path, but you will have to save the path if you want to
make this permanent or run `mpm init` next time your start matlab.

## Implementation detail

It relies on the linter used natively by matlab so it could also be extended to check all the messages relating to
all the little other issues in your code that you have not told matlab to ignore.

Also because octave does not have a linter, this will only work with matlab. 😭

## Automation

_Because we don't brush our teeth just the day before we go to the dentist._

If the `check_my_code` function is in the matlab path, you can automate its usage if you use Git for your project.

I have created a git hook that will execute the `check_my_code` every time you try to push to your
remote repository. If your code is not up to the standard then the push will be aborted.

To use this here is what you need to do:
1. Copy this file into your project/.git/hooks
2. Rename it to pre-push
3. You might need to modify the `alias matlab` line to point this script to where matlab is
    on your computer.
4. Make this file executable with `chmod +x .git/hooks/pre-push`
5. Now your code quality will be checked when you push your code to your remote.
