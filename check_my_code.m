function check_my_code()

m_ls = dir('*.m');

for i_m = 1:numel(m_ls)
    disp(m_ls(i_m).name)
    checkcode(m_ls(i_m).name, '-cyc')
end

end