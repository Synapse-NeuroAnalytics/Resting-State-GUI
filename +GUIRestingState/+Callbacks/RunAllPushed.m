function RunAllPushed(app, event) %#ok<INUSD>
% Run every step in order.
indices = 1:numel(app.Pipeline.Steps);
app.Pipeline.RunSteps(indices, app);
GUIRestingState.UI.RefreshStepRows(app, indices);
end
