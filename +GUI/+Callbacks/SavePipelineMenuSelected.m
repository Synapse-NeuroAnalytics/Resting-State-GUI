function SavePipelineMenuSelected(app, event) %#ok<INUSD>
% Saves the current pipeline to its configured PipelinePath.
if strlength(app.Pipeline.PipelinePath) == 0
    [f, p] = uiputfile("*.mat", "Save pipeline as");
    if isequal(f, 0)
        return
    end
    app.Pipeline.PipelinePath = string(fullfile(p, f));
end

app.Pipeline.UIState.Position = app.UIFigure.Position;
app.Pipeline.Overwrite = strcmp(app.OverwriteSwitch.Value, "On");

app.Pipeline.Save(app.Pipeline.PipelinePath);
GUI.Utils.Log(sprintf("Pipeline saved to %s.", app.Pipeline.PipelinePath), app);
end
