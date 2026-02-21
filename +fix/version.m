function v = version()
%FIX.VERSION Show version information for the fix toolbox.
%
% Usage:
%   fix.version()
%   v = fix.version()

    number = '1.0';

    [hash, branch, commitDate] = matlabGitInfo();

    if nargout == 0
        fprintf('\nfix toolbox\n');
        fprintf('------------\n');
        fprintf('Version : %s\n', number);

        if commitDate ~= ""
            fprintf('Built   : %s\n', commitDate);
        else
            fprintf('Built   : %s\n', fix.Version.Date);
        end

        if hash ~= ""
            fprintf('gitHash : %s', hash);
            if branch ~= ""
                fprintf('  (%s)', branch);
            end
            fprintf('\n');
        end

        fprintf('\n');
    else
        v = number;
    end
end

function [shortID, branchName, commitDate] = matlabGitInfo()

    shortID    = "";
    branchName = "";
    commitDate = "";

    fixFolder = fileparts(mfilename('fullpath')); % .../+fix
    repoRoot  = fileparts(fixFolder);             % one level above

    try
        repo = gitrepo(repoRoot);

        if ~isempty(repo.CurrentBranch)
            branchName = string(repo.CurrentBranch.Name);
        end

        commit = repo.LastCommit;

        % Short hash
        commitID = string(commit.ID);
        if strlength(commitID) >= 7
            shortID = extractBetween(commitID, 1, 7);
        else
            shortID = commitID;
        end

        % --- Choose ONE:
        dt = commit.AuthorDate;      % "created" date (usually what you want)
        % dt = commit.CommitterDate; % "applied" date (changes on rebase/amend)

        % dt is a datetime; format for display
        commitDate = string(datetime(dt, "Format", "yyyy-MM-dd HH:mm Z"));

    catch
        % not a git repo / not tracked / etc.
    end
end