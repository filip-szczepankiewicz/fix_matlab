function fix_computer_logoff(t_seconds)
% function fix_computer_logoff(t_seconds)

if nargin < 1
    t_seconds = 30;
end

t_seconds = round(t_seconds);

clc
msg = ['Matlab will Sign out the user in ' num2str(t_seconds) ' seconds!'];
disp(msg)
warndlg(msg)

for i = t_seconds:-1:1
    clc
    disp(['Matlab signing out in ' num2str(i) ' s! (Press Ctrl+C to abort)'])
    pause(1)
end

clc
warning('Matlab Signing out now!')
pause(1)
system('logoff')