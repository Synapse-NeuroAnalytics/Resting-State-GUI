function NewPipelineMenuSelected(app, event) %#ok<INUSD>
% Opens the New Pipeline popup dialog. If the
% user completes it, the current pipeline and step rows are rebuilt.
newPipeline = GUI.Windows.NewPipelineDialog(app);
if isempty(newPipeline)
    return  % user cancelled
end

app.Pipeline = newPipeline;
GUI.UI.UpdatePipelineDisplay(app);
GUI.UI.RebuildStepRows(app);
GUI.Utils.Log(sprintf("Created new pipeline '%s'.", app.Pipeline.PipelineName), app);
end
