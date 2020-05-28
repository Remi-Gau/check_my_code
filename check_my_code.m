function [error_code, file_function, cplx, percentage_comment] = check_my_code(recursive, cplx_thrs, comment_thres, print_file)
% This will give you the The McCabe complexity of all the `.m` files in the current directory. It will also
% return the complexity of the subfunctions in each file. If it gets above 10 you enter the
% danger zone. If you are above 15 you might seriously reconsider refactoring those functions.
%
% This function  also checks the proportion of lines with comments in each file (might overestimate it).
% In general you might want to try to be around 20%.
%
% This function will then list the functions that do not meet the requirements you have set for your projects.
% You can then use this information to figure out which function you should refactor first.
%
% FYI: The McCabe complexity of a function is presents how many paths one can take while navigating through
% the conditional statements of your function (`if`, `switch`, ...).
%
% ## USAGE
% If the check_my_code function is in the matlab path, then simply calling it will check the files in the
% the current directory.
%
% ### INPUTS
% #### recursive : BOOLEAN if set to true this will check the .m files in all the subfolders. (default: false)
%
% #### cplx_thrs : 1 X 2 ARRAY : thresholds for the acceptable McCabe complexity before triggering a warning.
%     Having 2 values lets you decide a zone of complexity that is high but acceptable and another that is
%     too high. (default: [15 20])
%
% #### comment_thres : 1 X 2 ARRAY : thresholds for the acceptable percentage of comments in a file
%     before triggering a warning.
%     Having 2 values lets you decide levels that are low but acceptable and another that is
%     too low. (default: [20 10])
%
% #### print_file : BOOLEAN this will print a file with the overall error code ; mostly used for automation
%     for now. (default: true)
%
% ### OUPUTS
%
% #### error_code
% an array wth [cplx_error_code comment_error_code] where each value is 0 if there is no file that
% is too complex or has too few comments and is 1 otherwise
%
% #### file_function
% a n X 2 cell listing of all the function in {i,1} and subfunction in {i,2} tested. If the function is
% the main function of a file then {i,1} and {i,2} are the same.
%
% #### cplx
% an array with the complexity of each function and subfunction
%
% #### percentage_comment
% an array with the percentage of comment in each file
%
% ## IMPLEMENTATION
%
% It relies on the linter used natively by matlab so it could also be extended to check all the messages relating to
% all the little other issues in your code that you have not told matlab to ignore.
%
% Because octave does not have a linter, so this will only work with matlab.

clc

% check inputs
if nargin<1 || isempty(recursive)
    recursive = false;
end

% those default threshold for the complexity and percentage are VERY
% liberal
if nargin<2 || isempty(cplx_thrs)
    cplx_thrs = [15 20];
end

if nargin<3 || isempty(comment_thres)
    comment_thres = [20 10];
end

if nargin<4 || isempty(print_file)
    print_file = false;
end

% initialize
cplx = [];
percentage_comment = [];
file_function = {};

% look through the folder for any m file that we want to check
if recursive
    % this will look recursively into all the subfolders
    if verLessThan('matlab', '9.2')
        warning('Your matlab verion is inferior to 2017a so I cannot recursively search subfolders. Sorry.')
        m_file_ls = dir('*.m');
    else
        m_file_ls = dir(fullfile(pwd, '**', '*.m'));
    end
else
    % this will look only in the current directory
    m_file_ls = dir('*.m');
end


for ifile = 1:numel(m_file_ls)

    filename = create_filename(m_file_ls, ifile);

    % get a rough idea of the percentage of comments
    percentage_comment(ifile) = get_percentage_comment(filename);

    fprintf('\n\n%s\n', m_file_ls(ifile).name)
    fprintf('Percentage of comments: %2.0f percent\n', percentage_comment(ifile))

    % get McCabe complexity
    msg = checkcode(filename, '-cyc');

    % Extract the complexity value of the functions and the subfunctions
    [file_function, cplx] = get_complexity(file_function, cplx, msg, filename);

end

% we actually check that the percentage of comments and the code complexity
% meets the requirements
fprintf(1,'\n')
fprintf(1,'\n-----------------------------------------------------------------------------------\n')
fprintf(1,'\n                              CHECK_MY_CODE REPORT                                 \n')
fprintf(1,'\n-----------------------------------------------------------------------------------\n')
fprintf(1,'\n')

cplx_error_code = report_cplx(cplx, file_function, cplx_thrs);

comment_error_code = report_comments(m_file_ls, percentage_comment, comment_thres);

error_code = [cplx_error_code comment_error_code];

if ~any(error_code)
    fprintf(1,'\n                       CONGRATULATIONS: YOUR CODE IS CLEAN                         \n')
end

fprintf(1,'\n-----------------------------------------------------------------------------------\n')
fprintf(1,'\n-----------------------------------------------------------------------------------\n')
fprintf(1,'\n')

if print_file
    fid = fopen(fullfile(pwd, 'check_my_code_report.txt'),...
        'Wt');
    fprintf(fid, '%i ', error_code);
    fclose(fid);
end

end

function percentage = get_percentage_comment(filename)
% Now we check how many lines have a "percent" sign in them which could
% indicate a comment of any sort
fid = fopen(filename);

line_count = 0;
comment_count = 0;

% loop through all the lines of the code and check which one starts with %
while 1
    tline = fgetl(fid);
    comment = strfind(tline, '%');
    if ~isempty(comment) %#ok<STREMP>
        comment_count = comment_count + 1;
    end
    if ~ischar(tline), break, end
    line_count = line_count + 1;
end

fclose(fid);

percentage = comment_count/line_count*100;
end

function [file_function, cplx] = get_complexity(file_function, cplx, msg, filename)

% In case this file is empty (i.e MEX file)
if isempty(msg)

    cplx(end+1) = 0;
    file_function{end+1,1} = filename; %#ok<*AGROW>
    file_function{end,2} = filename;

else

    % Loop through the messages and parses them to keep the name of the function and
    % subfunction and the complexity
    for iMsg = 1:numel(msg)

        if ~isempty(strfind(msg(iMsg).message, 'McCabe'))

            fprintf('%s\n', msg(iMsg).message)

            idx_1 = strfind(msg(iMsg).message, 'complexity of ');
            idx_2 = strfind(msg(iMsg).message, ' is ');

            % store names
            file_function{end+1,1} = filename; %#ok<*AGROW>
            file_function{end,2} = msg(iMsg).message(idx_1+15:idx_2-2);

            % store the complexity of this function
            cplx(end+1) = str2double(msg(iMsg).message(idx_2+4:end-1));

            % in case the file is empty
            if isnan(cplx(end))
                cplx(end) = 0;
            end

        end

    end

end
end

function comment_error_code = report_comments(m_file_ls, percentage_comment, comment_thres)
% this reports on the percentage of comments in the file
% we check what files have less comments thant the 2 threshold we have set
% and we throw a warning or an error depending on the threshold that has
% been crossed
% in either case we list the files incriminated.

warning_to_print = 'Not enough comments in the above functions';
error_to_print = 'Really not enough comments in the above functions !!!';

warning_comment = find(percentage_comment<comment_thres(1));
error_comment = find(percentage_comment<comment_thres(2));

comment_error_code = 0;

if ~isempty(warning_comment)

    for ifile = 1:numel(warning_comment)
        fprintf('\n%s',  create_filename(m_file_ls, warning_comment(ifile) ) )
    end

    fprintf('\n\n')
    warning(warning_to_print)

    comment_error_code = 1;

end

if ~isempty(error_comment)

    for ifile = 1:numel(error_comment)
        fprintf('\n%s',  create_filename(m_file_ls, error_comment(ifile) ) )
    end

    fprintf('\n\n')
    warning(upper(error_to_print))

    comment_error_code = 2;

end


end

function cplx_error_code = report_cplx(cplx, file_function, cplx_thrs)
% this reports on the complexity in the files
% we check what files have less comments thant the 2 threshold we have set
% and we throw a warning or an error depending on the threshold that has
% been crossed
% in either case we list the files incriminated.

warning_to_print = 'Above functions functions are too complex: you might want to refactor';
error_to_print = 'Above functions functions are way too complex: refactor them!!!';

warning_cplx = find(cplx>cplx_thrs(1));
error_cplx = find(cplx>cplx_thrs(2));

cplx_error_code = 0;

if ~isempty(warning_cplx)

    for ifile = 1:numel(warning_cplx)
        fprintf('\nthe function\t%s\n\tin the file %s', ....
            file_function{ warning_cplx(ifile), 2 }, ...
            file_function{ warning_cplx(ifile), 1 })
    end

    fprintf('\n\n')
    warning(warning_to_print)

    cplx_error_code = 1;

end

if ~isempty(error_cplx)

    for ifile = 1:numel(error_cplx)
        fprintf('\nthe function\t%s\n\tin the file %s', ....
            file_function{ error_cplx(ifile), 2 }, ...
            file_function{ error_cplx(ifile), 1 })
    end

    fprintf('\n\n')
    warning(upper(error_to_print))

    cplx_error_code = 1;

end


end

function filename = create_filename(m_file_ls, idx)
filename = fullfile(m_file_ls(idx).folder , m_file_ls(idx).name);
end
