function RunOnlyPushed(app, event, stepIndex) %#ok<INUSD>
% Run only this one step.
app.Pipeline.RunSteps(stepIndex, app);
GUIRestingState.UI.RefreshStepRows(app, stepIndex);
end
