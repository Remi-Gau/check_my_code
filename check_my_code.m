% (C) Copyright 2019 check_my_code developpers

function varargout = check_my_code(RECURSIVE, CPLX_THRS, COMMENT_THRS, PRINT_FILE)
    % [error_code, file_function, cplx, percentage_comment] = check_my_code(...
    %                                                              RECURSIVE, ...
    %                                                              CPLX_THRS, ...
    %                                                              COMMENT_THRS, ...
    %                                                              PRINT_FILE)
    %
    % This will give you the The McCabe complexity of all the `.m` files in the current
    %  directory.
    % It will also return the complexity of the subfunctions in each file. If it gets above 10
    %  you enter the danger zone. If you are above 15 you might seriously reconsider refactoring
    %  those functions.
    %
    % This function  also checks the proportion of lines with comments in each file
    %  (might overestimate it).
    % In general you might want to try to be around 20%.
    %
    % This function will then list the functions that do not meet the requirements you have
    % set for your projects.
    % You can then use this information to figure out which function you should refactor first.
    %
    % FYI: The McCabe complexity of a function is presents how many paths one can take while
    % navigating through the conditional statements of your function (`if`, `switch`, ...).
    %
    % ## USAGE
    % If the check_my_code function is in the matlab path, then simply calling it will check
    % the files in the the current directory.
    %
    % ### INPUTS
    % #### RECURSIVE : BOOLEAN if set to true this will check the .m files in all the
    %     subfolders. (default: false)
    %
    % #### CPLX_THRS : 1 X 2 ARRAY : thresholds for the acceptable McCabe complexity before
    %     triggering a warning.
    %     Having 2 values lets you decide a zone of complexity that is high but acceptable and
    %     another that is too high. (default: [15 20])
    %
    % #### COMMENT_THRS : 1 X 2 ARRAY : thresholds for the acceptable percentage of comments
    %     in a file before triggering a warning.
    %     Having 2 values lets you decide levels that are low but acceptable and another that
    %     is too low. (default: [20 10])
    %
    % #### PRINT_FILE : BOOLEAN this will print a file with the overall error code ; mostly
    %     used for automation for now. (default: true)
    %
    %
    % ### OUPUTS
    %
    % #### error_code
    %    an array wth [cplx_error_code comment_error_code] where each value is 0 if there is no
    %    file that is too complex or has too few comments and is 1 otherwise
    %
    % #### file_function
    %    A n X 2 cell listing of all the function in {i,1} and subfunction in {i,2} tested.
    %    If the function is the main function of a file then {i,1} and {i,2} are the same.
    %
    % #### cplx
    %    An array with the complexity of each function and subfunction
    %
    % #### percentage_comment
    %    An array with the percentage of comment in each file
    %
    %
    % ## IMPLEMENTATION
    %
    % It relies on the linter used natively by matlab so it could also be extended to check
    %  all the messages relating to all the little other issues in your code that you have not
    %  told matlab to ignore.
    %
    % Because octave does not have a linter, this will only work with matlab.

    clc;

    % check inputs
    if nargin < 1 || isempty(RECURSIVE)
        RECURSIVE = false;
    end

    % those default threshold for the complexity and percentage are VERY
    % liberal
    if nargin < 2 || isempty(CPLX_THRS)
        CPLX_THRS = [15 20];
    end

    if nargin < 3 || isempty(COMMENT_THRS)
        COMMENT_THRS = [20 10];
    end

    if nargin < 4 || isempty(PRINT_FILE)
        PRINT_FILE = false;
    end

    % initialize
    cplx = [];
    percentage_comment = [];
    file_function = {};

    % deal with old Matlab version differently
    if verLessThan('matlab', '9.2')
        if RECURSIVE
            m_file_ls = get_rec_file_ls(pwd);
        else
            m_file_ls = get_file_ls(pwd);
        end
    else
        % look through the folder for any m file that we want to check
        if RECURSIVE
            m_file_ls = dir(fullfile(pwd, '**', '*.m'));
        else
            m_file_ls = dir('*.m');
        end
    end

    for ifile = 1:numel(m_file_ls)

        filename = create_filename(m_file_ls, ifile);

        % get a rough idea of the percentage of comments
        percentage_comment(ifile) = get_percentage_comment(filename);

        fprintf('\n\n%s\n', m_file_ls(ifile).name);
        fprintf('Percentage of comments: %2.0f percent\n', percentage_comment(ifile));

        % get McCabe complexity
        msg = checkcode(filename, '-cyc');

        % Extract the complexity value of the functions and the subfunctions
        [file_function, cplx] = get_complexity(file_function, cplx, msg, filename);

    end

    % we actually check that the percentage of comments and the code complexity
    % meets the requirements
    fprintf(1, '\n');
    fprintf(1, '\n-----------------------------------------------------------------------\n');
    fprintf(1, '\n                        CHECK_MY_CODE REPORT                           \n');
    fprintf(1, '\n-----------------------------------------------------------------------\n');
    fprintf(1, '\n');

    comment_error_code = report_comments(m_file_ls, percentage_comment, COMMENT_THRS);

    cplx_error_code = report_cplx(cplx, file_function, CPLX_THRS);

    error_code = [cplx_error_code comment_error_code];

    if ~any(error_code)
        fprintf(1, '\n               CONGRATULATIONS: YOUR CODE IS CLEAN                 \n');
    end

    fprintf(1, '\n-----------------------------------------------------------------------\n');
    fprintf(1, '\n-----------------------------------------------------------------------\n');
    fprintf(1, '\n');

    if PRINT_FILE
        FID = fopen(fullfile(pwd, 'check_my_code_report.txt'), ...
            'Wt');
        fprintf(FID, '%i ', error_code);
        fclose(FID);
    end

    varargout = {error_code, file_function, cplx, percentage_comment};

end

function  m_file_ls = get_rec_file_ls(pth)
    % this returns the list of .m files in designated folder as well as
    % those from the sub-folders in a recursive way, which is not returned
    % by the 'dir' command in older Matlab versions.

    % start by get the current folder .m files and list of subfolders
    [m_file_ls, dir_ls] = get_file_ls(pth);
    n_subfs = size(dir_ls, 1);

    % check the subfolders
    if n_subfs
        for isubf = 1:n_subfs
            pth_subf = fullfile(pth, deblank(dir_ls(isubf, :)));
            m_file_lsubf = get_rec_file_ls(pth_subf);
            m_file_ls = [m_file_ls; m_file_lsubf];
        end
    end
end

function [m_file_ls, dir_ls] = get_file_ls(pth)
    % this returns the list of .m files in designated folder, including the
    % folder name, which is not returned by the 'dir' command in older
    % Matlab versions.
    % if requested, it also returns the list of subfolders, which is useful
    % for recursive folder-digging in older Matlab versions.

    m_file_ls = dir(fullfile(pth, '*.m'));

    % adding the 'folder' field which is missing, if there are some files
    if size(m_file_ls, 1) > 0

        m_file_ls(end).folder = [];

        for ifile = 1:numel(m_file_ls)
            m_file_ls(ifile).folder = pth;
        end

    else
        m_file_ls = [];

    end

    % look for subfolders
    if nargout == 2

        % get list of all 'subfolders'
        tmp_ls = dir(pth);
        dir_ls = char(tmp_ls([tmp_ls.isdir]).name);

        % remove those starting with a '.'
        dir_ls(strcmp(cellstr(dir_ls(:, 1)), '.'), :) = [];

    end
end

function filename = create_filename(m_file_ls, idx)

    filename = fullfile(m_file_ls(idx).folder, m_file_ls(idx).name);

end

function percentage = get_percentage_comment(filename)
    % Check how many lines have a "percent" sign in them which could
    % indicate a comment of any sort

    FID = fopen(filename);

    line_count = 0;
    comment_count = 0;

    % loop through all the lines of the code and check which one starts with %
    while 1
        tline = fgetl(FID);
        comment = strfind(tline, '%');
        if ~isempty(comment) %#ok<STREMP>
            comment_count = comment_count + 1;
        end
        if ~ischar(tline)
            break
        end
        line_count = line_count + 1;
    end

    fclose(FID);

    percentage = comment_count / line_count * 100;
end

function [file_function, cplx] = get_complexity(file_function, cplx, msg, filename)
    % Loop through the messages and parses them to keep the name of the function and
    % subfunction and the complexity

    % In case this file is empty (i.e MEX file)
    if isempty(msg)

        cplx(end + 1) = 0;
        file_function{end + 1, 1} = filename; %#ok<*AGROW>
        file_function{end, 2} = filename;

    else

        for iMsg = 1:numel(msg)

            if ~isempty(strfind(msg(iMsg).message, 'McCabe'))

                fprintf('%s\n', msg(iMsg).message);

                idx_1 = strfind(msg(iMsg).message, 'complexity of ');
                idx_2 = strfind(msg(iMsg).message, ' is ');

                % store names
                file_function{end + 1, 1} = filename; %#ok<*AGROW>
                file_function{end, 2} = msg(iMsg).message(idx_1 + 15:idx_2 - 2);

                % store the complexity of this function
                cplx(end + 1) = str2double(msg(iMsg).message(idx_2 + 4:end - 1));

                % in case the file is empty
                if isnan(cplx(end))
                    cplx(end) = 0;
                end

            end

        end

    end
end

function comment_error_code = report_comments(m_file_ls, percentage_comment, COMMENT_THRS)
    % This reports on the percentage of comments in the file
    %
    % We check what files have less comments thant the 2 threshold we have set
    % and we throw a warning or an error depending on the threshold that has
    % been crossed
    %
    % In either case we list the files incriminated.

    WARNING_TO_PRINT = 'Not enough comments in the above functions';
    ERROR_TO_PRINT = 'Really not enough comments in the above functions !!!';

    warning_comment = find(percentage_comment < COMMENT_THRS(1));
    error_comment = find(percentage_comment < COMMENT_THRS(2));

    comment_error_code = 0;

    if ~isempty(warning_comment)

        for ifile = 1:numel(warning_comment)
            fprintf('\n%s',  create_filename(m_file_ls, warning_comment(ifile)));
        end

        fprintf('\n\n');
        warning(WARNING_TO_PRINT);

        comment_error_code = 1;

    end

    if ~isempty(error_comment)

        for ifile = 1:numel(error_comment)
            fprintf('\n%s',  create_filename(m_file_ls, error_comment(ifile)));
        end

        fprintf('\n\n');
        warning(upper(ERROR_TO_PRINT));

        comment_error_code = 2;

    end

end

function cplx_error_code = report_cplx(cplx, file_function, CPLX_THRS)
    % this reports on the complexity in the files
    %
    % We check what files have less comments thant the 2 threshold we have set
    % and we throw a warning or an error depending on the threshold that has
    % been crossed.
    %
    % In either case we list the files incriminated.

    WARNING_TO_PRINT = 'Above functions functions are too complex: you might want to refactor';
    ERROR_TO_PRINT = 'Above functions functions are way too complex: refactor them!!!';

    warning_cplx = find(cplx > CPLX_THRS(1));
    error_cplx = find(cplx > CPLX_THRS(2));

    cplx_error_code = 0;

    if ~isempty(warning_cplx)

        for ifile = 1:numel(warning_cplx)
            fprintf('\nthe function\t%s\t, cplx : %d\n\tin the file %s', ....
                file_function{ warning_cplx(ifile), 2 }, ...
                cplx(warning_cplx(ifile)), ...
                file_function{ warning_cplx(ifile), 1 });
        end

        fprintf('\n\n');
        warning(WARNING_TO_PRINT);

        cplx_error_code = 1;

    end

    if ~isempty(error_cplx)

        for ifile = 1:numel(error_cplx)
            fprintf('\nthe function\t%s\t, cplx : %d\n\tin the file %s', ....
                file_function{ error_cplx(ifile), 2 }, ...
                cplx(error_cplx(ifile)), ...
                file_function{ error_cplx(ifile), 1 });
        end

        fprintf('\n\n');
        warning(upper(ERROR_TO_PRINT));

        cplx_error_code = 1;

    end

end
