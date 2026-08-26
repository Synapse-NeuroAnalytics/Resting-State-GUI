function RunOnlyPushed(app, event, stepIndex) %#ok<INUSD>
% Run only this one step.
app.Pipeline.RunSteps(stepIndex, app);
GUI.UI.RefreshStepRows(app, stepIndex);
end
