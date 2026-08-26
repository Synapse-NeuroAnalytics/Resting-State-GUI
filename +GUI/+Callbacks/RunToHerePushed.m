function RunToHerePushed(app, event, stepIndex) %#ok<INUSD>
% Run from the start of this step's phase through this step (inclusive).
phase = app.Pipeline.Steps(stepIndex).Phase;
phaseIdx = find(string({app.Pipeline.Steps.Phase}) == phase);
startIdx = phaseIdx(1);
indices = startIdx:stepIndex;

app.Pipeline.RunSteps(indices, app);
GUI.UI.RefreshStepRows(app, indices);
end