function check_my_code()
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


m_ls = dir('*.m');

for i_m = 1:numel(m_ls)
    
    fprintf('\n\n')
    
    disp(m_ls(i_m).name)
    
    % The McCabe complexity
    checkcode(m_ls(i_m).name, '-cyc')
    
    % Now we check how many lines have a "percent" sign in them which could
    % indicate a comment of any sort
    fid = fopen(m_ls(i_m).name);
    line_count = 0;
    comment_count = 0;
    while 1
        tline = fgetl(fid);
        comment = strfind(tline, '%');
        if ~isempty(comment)
            comment_count = comment_count + 1;
        end
        if ~ischar(tline), break, end
        line_count = line_count + 1;
    end
    fclose(fid);
    fprintf('Percentage of comments: %2.0f percent\n', comment_count/line_count*100)
end

end