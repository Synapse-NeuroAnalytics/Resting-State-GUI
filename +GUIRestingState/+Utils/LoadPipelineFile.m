function loaded = LoadPipelineFile(app, filepath)
% Loads a pipeline .mat file, applies the shared/synced-folder root-swap
% auto-fix, and - if any required paths are still missing afterward -
% prompts the user to redefine them or abort.
%
% Returns the loaded (and possibly path-corrected) GUIRestingState.Pipeline object,
% with PipelinePath set to filepath. Returns [] if the load failed, or
% the user chose to abort/cancel out of the missing-path prompt.
%
% This is the single entry point for loading a pipeline file, used by
% both LoadPipelineMenuSelected (loading while the app is already
% running) and startup (loading on first launch), so a relocated
% pipeline is checked/fixed the same way regardless of how it's opened.
arguments
    app
    filepath (1,1) string
end

loaded = [];

try
    candidate = GUIRestingState.Pipeline.Load(filepath);
catch ME
    uialert(app.UIFigure, "Could not load pipeline: " + ME.message, "Load failed");
    return
end

% Shared/synced-folder auto-fix: if this pipeline file is being opened
% from a different location than the one recorded when it was last
% saved (e.g. the same folder synced via OneDrive to a different drive
% letter or username on someone else's computer), detect the swapped
% "root" portion of the path and try applying the same swap to the
% raw/spreadsheet/output paths. Only applies where it actually resolves
% to a real file/folder - anything left broken still falls through to
% the missing-path prompt below.
oldPipelinePath = candidate.PipelinePath;
newPipelinePath = filepath;
if strlength(oldPipelinePath) > 0 && oldPipelinePath ~= newPipelinePath
    [oldRoot, newRoot] = GUIRestingState.Utils.FindCommonRootSwap(oldPipelinePath, newPipelinePath);
    if strlength(oldRoot) > 0
        candidate = GUIRestingState.Utils.ApplyRootSwap(candidate, oldRoot, newRoot);
        GUIRestingState.Utils.Log(sprintf("Pipeline opened from a different location than saved ('%s' -> '%s'); auto-matched paths where possible.", ...
            oldRoot, newRoot), app);
    end
end

required = GUIRestingState.Pipeline.RequiredPaths(candidate);
fieldsToCheck = ["SpreadsheetPath", "RawDataPath", "OutputPath"];
missing = strings(0);
for k = 1:numel(fieldsToCheck)
    val = required.(fieldsToCheck(k));
    exists = (isfile(val) || isfolder(val));
    if strlength(val) > 0 && ~exists
        missing(end+1) = fieldsToCheck(k); %#ok<AGROW>
    end
end

if ~isempty(missing)
    msg = "The following paths from this pipeline no longer exist:" + newline + ...
        strjoin("  - " + missing, newline) + newline + newline + ...
        "Abort loading, or redefine them now?";
    choice = uiconfirm(app.UIFigure, msg, "Missing paths", ...
        "Options", ["Redefine", "Abort"], "DefaultOption", 2, "CancelOption", 2);
    if choice == "Abort"
        GUIRestingState.Utils.Log("Load pipeline aborted (missing paths).", app);
        loaded = [];
        return
    end

    existingValues = struct( ...
        "TaskName",        candidate.TaskName, ...
        "PipelineName",    candidate.PipelineName, ...
        "PipelinePath",    candidate.PipelinePath, ...
        "SpreadsheetPath", candidate.SpreadsheetPath, ...
        "RawDataPath",     candidate.RawDataPath, ...
        "OutputPath",      candidate.OutputPath);

    updatedPaths = GUIRestingState.Windows.NewPipelineDialog(app, "redefine", existingValues);
    if isempty(updatedPaths)
        GUIRestingState.Utils.Log("Load pipeline aborted (paths not redefined).", app);
        loaded = [];
        return
    end

    candidate.RawDataPath     = updatedPaths.RawDataPath;
    candidate.SpreadsheetPath = updatedPaths.SpreadsheetPath;
    candidate.OutputPath      = updatedPaths.OutputPath;
end

candidate.PipelinePath = filepath;
loaded = candidate;
end
