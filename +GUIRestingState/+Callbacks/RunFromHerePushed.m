function RunFromHerePushed(app, event, stepIndex) %#ok<INUSD>
% Run from this step through the end of this step's phase.
phase = app.Pipeline.Steps(stepIndex).Phase;
phaseIdx = find(string({app.Pipeline.Steps.Phase}) == phase);
endIdx = phaseIdx(end);
indices = stepIndex:endIdx;

app.Pipeline.RunSteps(indices, app);
GUIRestingState.UI.RefreshStepRows(app, indices);
end
