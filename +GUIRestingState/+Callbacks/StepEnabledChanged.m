function StepEnabledChanged(app, event, stepIndex)
% Enables/disables individual steps.
app.Pipeline.Steps(stepIndex).Enabled = logical(event.Value);
GUIRestingState.Utils.Log(sprintf("Step %s %s.", app.Pipeline.Steps(stepIndex).ID, ...
    string(logical(event.Value)) + " (Enabled)"), app);

GUIRestingState.Utils.MarkDownstreamDirty(app);

if strlength(app.Pipeline.PipelinePath) > 0
    app.Pipeline.Save(app.Pipeline.PipelinePath);
end
end