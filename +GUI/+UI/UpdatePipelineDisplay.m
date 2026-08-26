function UpdatePipelineDisplay(app)
% Updates header label and window title with active pipeline name.
if ~isempty(app.Pipeline) && isprop(app.Pipeline, 'PipelineName') && strlength(app.Pipeline.PipelineName) > 0
    pName = app.Pipeline.PipelineName;

    if isprop(app, 'PipelineLabel') && ~isempty(app.PipelineLabel) && isvalid(app.PipelineLabel)
        app.PipelineLabel.Text = "Pipeline: " + pName;
    end

    if ~isempty(app.UIFigure) && isvalid(app.UIFigure)
        app.UIFigure.Name = "fNIRS Preprocessing GUI - " + pName;
    end
end
end