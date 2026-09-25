function NewPipelineMenuSelected(app, event) %#ok<INUSD>
% Opens the New Pipeline popup dialog. If the
% user completes it, the current pipeline and step rows are rebuilt.
newPipeline = GUIRestingState.Windows.NewPipelineDialog(app);
if isempty(newPipeline)
    return  % user cancelled
end

app.Pipeline = newPipeline;
GUIRestingState.UI.UpdatePipelineDisplay(app);
GUIRestingState.UI.RebuildStepRows(app);
GUIRestingState.Utils.Log(sprintf("Created new pipeline '%s'.", app.Pipeline.PipelineName), app);
end
