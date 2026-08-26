function ids = NonDataChangingStepIDs()
% Returns the IDs of steps that do not modify the data.
% Used in:
%   MarkDownstreamDirty - enabling/disabling one of these steps does
%      not mark downstream steps as needing a rerun.
%   BuildOneStepRow / RefreshStepRows - permanently lock "generate figures"
%       to be on for these steps.
ids = ["2.2", "3.8", "3.11"];
end
