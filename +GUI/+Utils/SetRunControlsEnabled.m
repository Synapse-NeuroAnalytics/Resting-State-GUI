function SetRunControlsEnabled(app, tf)
% Enables/disables all "start a run" controls (master Run All + each
% step's Run Only/To Here/From Here buttons) together, and sets the
% Stop button to the opposite state. Called at the start/end of
% Pipeline.RunSteps so the user can't start an overlapping run.
arguments
    app
    tf (1,1) logical
end

if isprop(app, 'RunAllButton') && isvalid(app.RunAllButton)
    app.RunAllButton.Enable = tf;
end

if ~isempty(app.StepHandles)
    for i = 1:numel(app.StepHandles)
        h = app.StepHandles(i);
        for fname = ["RunOnlyButton", "RunFromHereButton", "RunToHereButton"]
            if isfield(h, fname) && ~isempty(h.(fname)) && isvalid(h.(fname))
                h.(fname).Enable = tf;
            end
        end
    end
end

if isprop(app, 'StopButton') && isvalid(app.StopButton)
    app.StopButton.Enable = ~tf;
end
end
