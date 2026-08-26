function MarkDownstreamDirty(app, fromIndex)
% Marks specified step and downstream steps as needing a rerun.
arguments
    app
    fromIndex (1,1) double = 1
end

if isempty(app.Pipeline) || isempty(app.Pipeline.Steps)
    return
end

exemptIDs = GUI.Utils.NonDataChangingStepIDs();

n = numel(app.Pipeline.Steps);
anyUpstreamDirty = false;

for i = 1:n
    s = app.Pipeline.Steps(i);

    % Disabled steps don't run, so parameter edits made while a step is
    % disabled have no effect on the output and shouldn't dirty anything.
    % Beyond that, each parameter independently controls:
    %   MarksDirty      - does changing it flag THIS step as needing a rerun
    %   PropagatesDirty - does changing it flag DOWNSTREAM steps too
    % e.g. a cosmetic figure-only option can flag its own step (the figure
    % needs regenerating) without forcing every step after it to rerun.
    paramChangedLocal = false;
    paramChangedPropagate = false;
    if s.Enabled
        hasDirtyFields = ~isempty(s.Parameters) && all(isfield(s.Parameters, {'MarksDirty', 'PropagatesDirty'}));
        for p = 1:numel(s.Parameters)
            if isequaln(s.Parameters(p).Value, s.Parameters(p).LastRunValue)
                continue
            end
            if ~hasDirtyFields || s.Parameters(p).MarksDirty
                paramChangedLocal = true;
            end
            if ~hasDirtyFields || s.Parameters(p).PropagatesDirty
                paramChangedPropagate = true;
            end
        end
    end

    % Toggling a step's Enabled state is treated the same as changing a
    % parameter, except for steps that don't actually change the data
    % (e.g. figure-only/diagnostic steps).
    enabledChanged = ~any(strcmp(s.ID, exemptIDs)) && (s.Enabled ~= s.LastRunEnabled);

    isDirty = paramChangedLocal || enabledChanged || anyUpstreamDirty;
    app.Pipeline.Steps(i).NeedsRerun = isDirty;

    if paramChangedPropagate || enabledChanged || anyUpstreamDirty
        anyUpstreamDirty = true;
    end
end

GUI.UI.RefreshStepRows(app, 1:n);
end
