function GenerateFiguresChanged(app, event, stepIndex)
% Toggle individual step figure generation.
app.Pipeline.Steps(stepIndex).GenerateFigures = logical(event.Value);
GUIRestingState.Utils.Log(sprintf("Step %s: generate figures set to %s.", ...
    app.Pipeline.Steps(stepIndex).ID, string(logical(event.Value))), app);
end
