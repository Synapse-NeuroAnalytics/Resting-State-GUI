function [oldRoot, newRoot] = FindCommonRootSwap(oldPath, newPath)
% Compares two versions of "the same" path - e.g. a pipeline .mat file's
% recorded save location vs. the location it was actually just opened
% from - and returns the differing leading "root" portion of each,
% trimmed back to a folder-separator boundary.
%
% This is what makes a shared/synced pipeline folder (e.g. a OneDrive
% folder mapped to a different drive letter or username on someone
% else's machine) portable: everything after the shared tail (e.g.
% "\Test_Data\...") is assumed identical, and only the personal prefix
% in front of it is assumed to have changed.
%
% Example:
%   oldPath = "H:\Synapse NeuroAnalytics\Androu...\Test_Data\2026-08-17_rest.mat"
%   newPath = "C:\Users\Yuejia\OneDrive - Synapse\...\Test_Data\2026-08-17_rest.mat"
%   -> oldRoot = "H:\Synapse NeuroAnalytics\Androu..."
%      newRoot = "C:\Users\Yuejia\OneDrive - Synapse\..."
%
% If no usable folder-boundary-aligned match is found, both outputs are "".
arguments
    oldPath (1,1) string
    newPath (1,1) string
end

oldChars = char(oldPath);
newChars = char(newPath);

suffixLen = 0;
maxLen = min(length(oldChars), length(newChars));
while suffixLen < maxLen && oldChars(end - suffixLen) == newChars(end - suffixLen)
    suffixLen = suffixLen + 1;
end

% Trim back to the nearest folder separator so we swap whole folder
% names rather than part of one.
while suffixLen > 0 && ~any(oldChars(end - suffixLen + 1) == '\/')
    suffixLen = suffixLen - 1;
end

if suffixLen == 0 || suffixLen >= maxLen
    oldRoot = "";
    newRoot = "";
    return
end

oldRoot = string(oldChars(1:end - suffixLen));
newRoot = string(newChars(1:end - suffixLen));

if oldRoot == newRoot
    oldRoot = "";
    newRoot = "";
end
end
