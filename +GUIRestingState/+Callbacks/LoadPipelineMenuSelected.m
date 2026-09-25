function LoadPipelineMenuSelected(app, event) %#ok<INUSD>
% Loads a pipeline .mat file. If any referenced paths no longer exist,
% asks the user to abort or redefine them.

% Start the browser in the current pipeline's folder (if one is loaded
% and that folder still exists), rather than MATLAB's current working
% folder.
startDir = "";
if ~isempty(app.Pipeline) && isprop(app.Pipeline, 'PipelinePath') && strlength(app.Pipeline.PipelinePath) > 0
    candidateDir = fileparts(app.Pipeline.PipelinePath);
    if isfolder(candidateDir)
        startDir = string(candidateDir);
    end
end
if strlength(startDir) == 0
    startDir = string(pwd);
end

[f, p] = uigetfile(fullfile(startDir, "*.mat"), "Load pipeline");
if isequal(f, 0)
    return
end
filepath = fullfile(p, f);

loaded = GUIRestingState.Utils.LoadPipelineFile(app, string(filepath));
if isempty(loaded)
    return
end

app.Pipeline = loaded;
GUIRestingState.UI.UpdatePipelineDisplay(app);
GUIRestingState.UI.RebuildStepRows(app);
GUIRestingState.Utils.Log(sprintf("Loaded pipeline '%s' from %s.", app.Pipeline.PipelineName, filepath), app);
end
