% (C) Copyright 2019 check_my_code developpers

function test_check_my_code()

    pth = fileparts(mfilename('fullpath'));

    cd(fullfile(pth, '..'));

    cplx_thrs = [15 20];
    comment_thres = [20 10];
    print_file = false;

    % make sure that the check_my_code itself is up to the standard
    recursive = false;
    error_code = check_my_code(recursive, cplx_thrs, comment_thres, print_file);

    assert(~any(error_code));

    % make sure that the bad_function in the test subfolder does not pass the
    % test.
    recursive = true;
    error_code = check_my_code(1, [], [], 0);

    assert(any(error_code));

end
