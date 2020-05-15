#!/bin/sh

clear

# If you want to change how strict the rules are.
cplx_thrs='[15 20]'
comment_thres='[20 10]'

# depending on your matlab install you might need to create an alias for this to work.
alias matlab="/usr/local/MATLAB/R2017a/bin/matlab"

FILE='check_my_code_report.txt'


echo "\n\n🚧 🚧 🚧 Checking code quality before pushing. 🚧 🚧 🚧\n\n"

if [ -f "$FILE" ]; then
    rm $FILE
fi

matlab -nojvm -nosplash -r "if exist('check_my_code', 'file')==2 ; check_my_code(1, $cplx_thrs, $comment_thres, 1); end; exit;"

[ -s "$FILE" ]

if [ "$?" = "0" ]; then

  echo "\n\n🚧 🚧 🚧 You can't push until your code been properly cleaned. 🚧 🚧 🚧\n\n"

  # if you remove this line then it won't block push but send message on command line
  exit 1

else

  echo "\n\n🎉 🎉 🎉 Your code is good to push. 🎉 🎉 🎉\n\n"

  exit 0

fi
