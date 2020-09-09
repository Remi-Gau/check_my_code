% (C) Copyright 2019 check_my_code developpers

function [] = good_function()
    % GOOD_FUNCTION

    CONST_1 = rand() * 10;
    CONST_2 = 10;

    for i = 1:CONST_2

        % This is how you can refactor your code
        if CONST_1 > 5

            % Use subfunctions
            what_to_do_1(i);

        else

            % Use many subfunctions
            what_to_do_2(i);

        end

    end

end

function what_to_do_1(i)
    % This is explains what this subfunction does

    if i < 1
    elseif i == 1
        % in
    elseif i == 2
        % every
    elseif i == 3
        % single
    elseif i == 4
        % case
    elseif i == 5
        % tell
    elseif i == 6
        % me
    elseif i == 7
        % what
    elseif i == 8
        % is
    elseif i == 9
        % happening
    elseif i == 10
    else
    end
end

function what_to_do_2(i)
    if i < 1
    elseif i == 1
        % in
    elseif i == 2
        % every
    elseif i == 3
        % single
    elseif i == 4
        % case
    elseif i == 5
        % tell
    elseif i == 6
        % me
    elseif i == 7
        % what
    elseif i == 8
        % is
    elseif i == 9
        % happening
    elseif i == 10
    else
    end
end
