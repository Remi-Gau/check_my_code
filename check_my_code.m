function [error_code, file_function, cplx, percentage_comment] = check_my_code(recursive, cplx_thrs, comment_thres, print_file)
% A very silly function that will give you the The McCabe complexity of all
% the m files in a folder. It will also return the complexity of the
% subfunctions in each file
%
% Also checks the proportion of lines with comments in each file (might
% overestimate it).
%
% It relies on the linter used natively by matlab so it will also outputs
% all the messages relating to all the little other issues in your code
% that you have not told matlab to ignore

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
    print_file = true;
end

% initialize
cplx = [];
percentage_comment = [];
file_function = {};

% look through the folder for any m file that we want to check
if recursive
    % this will look recursively into all the subfolders
    m_file_ls = dir(fullfile(pwd, '**', '*.m'));
else
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
        
        if contains(msg(iMsg).message, 'McCabe')
            
            fprintf('%s\n', msg(iMsg).message)
            
            idx_1 = strfind(msg(iMsg).message, 'complexity of ');
            idx_2 = strfind(msg(iMsg).message, ' is ');
            
            % store names
            file_function{end+1,1} = filename; %#ok<*AGROW>
            file_function{end,2} = msg(iMsg).message(idx_1+15:idx_2-2);
            
            % store the complexity of this function
            cplx(end+1) = str2double(msg(iMsg).message(idx_2+4:end-1));
            
        end
        
        % in case the file is empty
        if isnan(cplx(end))
            cplx(end) = 0;
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