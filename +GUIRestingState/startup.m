function startup(app)
% Entry point called from the .mlapp file's startupFcn.
arguments
    app
end

%% Verify that the fNIRS-Preprocessing project is on the path and start it
if GUIRestingState.Pipeline.TEST_MODE
    warning("Test mode is enabled. fNIRS-Preprocessing will not be used.")
elseif ~exist("startfNIRSPreprocessing", "file")
    % Not on path, do error popup
    errordlg("Failed to locate fNIRS-Preprocessing. Please call ""startfNIRSPreprocessing.m"" once to add it to the path.", "fNIRS-Preprocessing")
    
    % Close UI figure
    if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
        app.UIFigure.CloseRequestFcn = '';
        delete(app.UIFigure);
    end

    % Stop
    return
else
    % On path, start it
    startfNIRSPreprocessing;
end

%%

choice = uiconfirm(app.UIFigure, ...
    "Create a new pipeline, or load an existing one?", ...
    "fNIRS Preprocessing GUI", ...
    "Options", ["New pipeline", "Load pipeline", "Cancel"], ...
    "DefaultOption", 1, ...
    "CancelOption", 3);

pipeline = [];
switch choice
    case "New pipeline"
        pipeline = GUIRestingState.Windows.NewPipelineDialog(app);
    case "Load pipeline"
        [f, p] = uigetfile("*.mat", "Load pipeline");
        if ~isequal(f, 0)
            filepath = fullfile(p, f);
            pipeline = GUIRestingState.Utils.LoadPipelineFile(app, string(filepath));
        end
    otherwise
        % Cancel option
end

if isempty(pipeline)
    % Close UI figure
    if isprop(app, 'UIFigure') && isvalid(app.UIFigure)
        app.UIFigure.CloseRequestFcn = '';
        delete(app.UIFigure);
    end
    return
end

% Assign pipeline and set the log file path
app.Pipeline = pipeline;
app.LogFilePath = fullfile(pipeline.OutputPath, "derivatives", "execution.log");

% Set main colours
app.PhaseColors = struct( ...
    "Import",          [0.733, 0.792, 0.737], ... 
    "QualityControl",  [0.867, 0.973, 0.996], ...  
    "Preprocessing",   [0.749, 0.82, 0.655]); 
app.DirtyColor = [0.678, 0.169, 0.169];   
app.OtherColors.InputBackground = [1 1 1];
% Same saturation/brightness as DirtyColor (HSV S=0.75, V=0.68), just
% rotated to an orange hue - used to mark steps as queued/in-progress
% during a run so progress is visible without watching the log.
app.OtherColors.RunningColor = [0.678, 0.423, 0.169];

GUIRestingState.UI.UpdatePipelineDisplay(app);
GUIRestingState.UI.BuildStepRows(app);
GUIRestingState.Utils.Log("fNIRS Preprocessing GUI started.", app);
end
