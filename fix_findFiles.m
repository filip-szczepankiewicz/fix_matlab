function fnl = fix_findFiles(maindir, strSearch)
% function fnl = fix_findFiles(maindir, strSearch)

fileList = dir(fullfile(maindir, '**', strSearch));

nFiles = numel(fileList);
fnl    = cell(nFiles,1);

for i = 1:numel(fileList)
    fnl{i} = [fileList(i).folder filesep fileList(i).name];
end
