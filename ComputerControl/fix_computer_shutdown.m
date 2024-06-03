function fix_computer_shutdown(t_seconds)
% function fix_computer_shutdown(time)
% Shuts down Windows in "time" seconds. If no argument is given the
% shutdown is aborted.

if nargin < 1
    % abort shutdown
    system('shutdown -a')
    disp('Signal to abort shutdown has been sent to system!')
    return
end

t_seconds = round(t_seconds);

clc
msg = ['Matlab will shut down the computer in ' num2str(t_seconds) ' seconds!'];
disp(msg)
warndlg(msg);

for i = t_seconds:-1:1
    clc
    msg = ['Matlab is shutting down computer in ' num2str(i) ' s! (Press Ctrl+C to abort)'];
    disp(msg)
    pause(1)
end

clc
warning('Matlab is shutting down now!')

system('shutdown -s -f -t 5')