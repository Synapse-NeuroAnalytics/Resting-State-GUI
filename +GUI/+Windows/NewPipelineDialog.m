function result = NewPipelineDialog(parentApp, mode, existingValues)
% Dialog to initialize and configure a new pipeline, OR (mode = "redefine")
% to fix up the paths of an already-loaded pipeline whose files/folders
% have moved or been deleted. Same popup, reused, prepopulated.
arguments
    parentApp = []
    mode (1,1) string {mustBeMember(mode, ["new", "redefine"])} = "new"
    existingValues struct = struct()
end

testTask        = getOrDefault(existingValues, "TaskName", "rest");
testRawPath     = getOrDefault(existingValues, "RawDataPath", "");
testSpreadsheet = getOrDefault(existingValues, "SpreadsheetPath", "");
testOutputPath  = getOrDefault(existingValues, "OutputPath", "");
testPipelineName = getOrDefault(existingValues, "PipelineName", "");
testPipelinePath  = getOrDefault(existingValues, "PipelinePath", "");

isRedefine = (mode == "redefine");

result = [];
fig = uifigure("Name", "New Pipeline", "Position", [0 0 560 400]);
fig.Theme = "light";
movegui(fig, "center");

% Shared "last browsed directory" - every Browse button in this dialog
% reads/updates this, so picking a folder for one field starts the next
% field's browser in the same place, regardless of which button is
% clicked next. Seeded from any pre-existing path (useful in "redefine"
% mode where paths are already partially filled in).
initialLastDir = "";
for candidate = [testOutputPath, testRawPath, testSpreadsheet, testPipelinePath]
    candidate = strtrim(candidate);
    if strlength(candidate) == 0
        continue
    end
    if isfolder(candidate)
        initialLastDir = candidate;
        break
    elseif isfile(candidate)
        [folder, ~, ~] = fileparts(candidate);
        initialLastDir = string(folder);
        break
    end
end
if strlength(initialLastDir) == 0
    initialLastDir = string(pwd);
end
setappdata(fig, "LastBrowseDir", initialLastDir);

g = uigridlayout(fig, [8, 2]);
g.RowHeight = {30, "fit", "fit", "fit", "fit", "fit", "fit", 40};
g.ColumnWidth = {180, "1x"};
g.Padding = [20 20 20 20];
g.RowSpacing = 14;

if isRedefine
    titleText = "One or more paths for this pipeline no longer exist. Please update them below:";
else
    titleText = "Create a pipeline by entering in the following fields:";
end
titleLbl = uilabel(g, "Text", titleText, "FontWeight", "bold", "FontSize", 14, "WordWrap", "on");
titleLbl.Layout.Row = 1; titleLbl.Layout.Column = [1 2];

lbl = uilabel(g, "Text", "Task Name", "FontWeight", "bold");
lbl.Layout.Row = 2; lbl.Layout.Column = 1;
taskField = uieditfield(g, "text", "Value", testTask, "Placeholder", "E.g. Rest");
taskField.Layout.Row = 2; taskField.Layout.Column = 2;
taskField.Tooltip = "Name of the task/condition being processed (default: rest).";

lbl = uilabel(g, "Text", "Pipeline Name", "FontWeight", "bold");
lbl.Layout.Row = 3; lbl.Layout.Column = 1;
if isRedefine && strlength(testPipelineName) > 0
    defaultName = testPipelineName;
else
    defaultName = string(datetime("now", "Format", "yyyy-MM-dd")) + "_" + taskField.Value;
end
nameField = uieditfield(g, "text", "Value", defaultName);
nameField.Layout.Row = 3; nameField.Layout.Column = 2;
nameField.Tooltip = "Default: DATE_TASK (e.g., 2026-07-28_rest)";

lbl = uilabel(g, "Text", "Path to save pipeline", "FontWeight", "bold");
lbl.Layout.Row = 4; lbl.Layout.Column = 1;
lbl.Tooltip = "Saves: All file paths and input parameters";
if isRedefine && strlength(testPipelinePath) > 0
    initialPipelinePath = testPipelinePath;
else
    initialPipelinePath = fullfile(pwd, nameField.Value + ".mat");
end
pipelinePathRow = pathPickerRow(g, 4, 2, initialPipelinePath, "file-save", "*.mat", "Select the location to save the pipeline .mat file to");

taskField.ValueChangedFcn = @(~,~) updateDefaultName();
nameField.ValueChangedFcn = @(~,~) updatePipelinePath();

if isRedefine
    % Renaming or re-pointing the pipeline file itself isn't the point of
    % this flow - only the raw/spreadsheet/output paths are editable.
    taskField.Enable = "off";
    nameField.Enable = "off";
    pipelinePathRow.EditField.Enable = "off";
    pipelinePathRow.BrowseButton.Enable = "off";
end

lbl = uilabel(g, "Text", "Path to raw data", "FontWeight", "bold");
lbl.Layout.Row = 5; lbl.Layout.Column = 1;
rawPathRow = pathPickerRow(g, 5, 2, testRawPath, "folder", "", "Select the folder containing all raw data");

labelWithHelp = uigridlayout(g, [1 2]);
labelWithHelp.Layout.Row = 6; labelWithHelp.Layout.Column = 1;
labelWithHelp.ColumnWidth = {"1x", 24};
labelWithHelp.Padding = [0 0 0 0];
labelWithHelp.ColumnSpacing = 4;
lbl = uilabel(labelWithHelp, "Text", "Path to data spreadsheet", "FontWeight", "bold");
lbl.Layout.Row = 1; lbl.Layout.Column = 1;
helpBtn = uibutton(labelWithHelp, "Text", "?", "FontWeight", "bold", "Tooltip", ...
    "The dataset spreadsheet lists one row per acquisition with its file location, participant info, and manual values.");
helpBtn.Layout.Row = 1; helpBtn.Layout.Column = 2;

spreadRowGrid = uigridlayout(g, [2 1]);
spreadRowGrid.Layout.Row = 6; spreadRowGrid.Layout.Column = 2;
spreadRowGrid.RowHeight = {"fit", "fit"};
spreadRowGrid.Padding = [0 0 0 0];
spreadRowGrid.RowSpacing = 4;

spreadsheetPathRow = pathPickerRow(spreadRowGrid, 1, 1, testSpreadsheet, "file-open", "*.csv; *.xls; *.xlsx", "Select the acquisition information spreadsheet");

templateRow = uigridlayout(spreadRowGrid, [1 2]);
templateRow.Layout.Row = 2;
templateRow.ColumnWidth = {"1x", 110};
templateRow.Padding = [0 0 0 0];
templateHintLbl = uilabel(templateRow, "Text", "To create a new spreadsheet template, choose a folder, then click Create.", ...
    "FontColor", [0.4 0.4 0.4], "FontSize", 11, "WordWrap", "on");
templateHintLbl.Layout.Row = 1; templateHintLbl.Layout.Column = 1;

csvBtn = uibutton(templateRow, "Text", "Create .csv", "ButtonPushedFcn", @(~,~) createTemplate());
csvBtn.Layout.Row = 1; csvBtn.Layout.Column = 2;
if isRedefine
    csvBtn.Enable = "off";
    templateHintLbl.Text = "Select the existing spreadsheet for this pipeline.";
end

lbl = uilabel(g, "Text", "Path to save output data", "FontWeight", "bold");
lbl.Layout.Row = 7; lbl.Layout.Column = 1;
lbl.Tooltip = "Includes: Figures, time courses, and execution log.";
outputPathRow = pathPickerRow(g, 7, 2, testOutputPath, "folder", "", "Select the location for all outputs");

if isRedefine
    doneBtnText = "Update paths";
else
    doneBtnText = "Done";
end
doneBtn = uibutton(g, "Text", doneBtnText, "BackgroundColor", [0.85 0.5 0.45], ...
    "FontColor", "white", "FontWeight", "bold", "ButtonPushedFcn", @(~,~) onDone());
doneBtn.Layout.Row = 8; doneBtn.Layout.Column = [1 2];

uiwait(fig);

    function updateDefaultName()
        nameField.Value = string(datetime("now", "Format", "yyyy-MM-dd")) + "_" + taskField.Value;
        updatePipelinePath();
    end

    function updatePipelinePath()
        currentPath = strtrim(pipelinePathRow.EditField.Value);
        if strlength(currentPath) == 0
            lastDir = getappdata(fig, "LastBrowseDir");
            if isempty(lastDir) || strlength(lastDir) == 0
                folder = pwd;
            else
                folder = lastDir;
            end
        else
            [folder, ~, ~] = fileparts(currentPath);
            if strlength(folder) == 0, folder = pwd; end
        end
        pName = strtrim(nameField.Value);
        if strlength(pName) == 0, pName = "pipeline"; end
        pipelinePathRow.EditField.Value = fullfile(folder, pName + ".mat");
    end

    function createTemplate()
        lastDir = getappdata(fig, "LastBrowseDir");
        if isempty(lastDir) || strlength(lastDir) == 0
            lastDir = string(pwd);
        end

        targetPath = strtrim(spreadsheetPathRow.EditField.Value);
        
        if strlength(targetPath) == 0
            initialPath = fullfile(lastDir, "AcquisitionInfo_" + taskField.Value + ".csv");
        elseif isfolder(targetPath)
            initialPath = fullfile(targetPath, "AcquisitionInfo_" + taskField.Value + ".csv");
        else
            initialPath = targetPath;
        end
        
        [f, p] = uiputfile("*.csv", "Choose folder & name for new template", initialPath);
        if isequal(f, 0), return; end
        targetPath = fullfile(p, f);
        setappdata(fig, "LastBrowseDir", string(p));

        try
            GUI.Windows.CreateSpreadsheetTemplate(targetPath, rawPathRow.EditField.Value);
            spreadsheetPathRow.EditField.Value = targetPath;
            uialert(fig, "Template created successfully at:" + newline + targetPath, "Success", "Icon", "success");
        catch ME
            uialert(fig, "Could not create template: " + ME.message, "Error");
        end
    end

    function onDone()
        if isRedefine
            % Only hand back the paths - the caller applies these to the
            % pipeline it already has loaded (Steps, etc. untouched).
            newRawPath     = string(rawPathRow.EditField.Value);
            newOutputPath  = string(outputPathRow.EditField.Value);
            newSpreadsheet = string(spreadsheetPathRow.EditField.Value);

            if strlength(newRawPath) == 0 || strlength(newOutputPath) == 0
                uialert(fig, "Please fill in at least the raw data and output paths.", "Missing information");
                return
            end

            result = struct( ...
                "RawDataPath",     newRawPath, ...
                "SpreadsheetPath", newSpreadsheet, ...
                "OutputPath",      newOutputPath);

            uiresume(fig);
            delete(fig);
            return
        end

        p = GUI.Pipeline();
        p.TaskName        = string(taskField.Value);
        p.PipelineName    = string(nameField.Value);
        p.PipelinePath    = string(pipelinePathRow.EditField.Value);
        p.SpreadsheetPath = string(spreadsheetPathRow.EditField.Value);
        p.RawDataPath     = string(rawPathRow.EditField.Value);
        p.OutputPath      = string(outputPathRow.EditField.Value);
        
        if strlength(p.PipelinePath) == 0 || strlength(p.RawDataPath) == 0 || strlength(p.OutputPath) == 0
            uialert(fig, "Please fill in at least the pipeline, raw data, and output paths.", "Missing information");
            return
        end

        logDir = fullfile(p.OutputPath, "derivatives");
        if ~isfolder(logDir), mkdir(logDir); end

        try
            p.Save(p.PipelinePath);
        catch ME
            uialert(fig, "Could not save initial pipeline file: " + ME.message, "Save Error");
            return
        end

        result = p;
        uiresume(fig);
        delete(fig);
    end
end

function v = getOrDefault(s, fieldName, defaultVal)
% Small helper: reads a field from a struct if present, else returns default.
if isfield(s, fieldName) && strlength(string(s.(fieldName))) > 0
    v = string(s.(fieldName));
else
    v = string(defaultVal);
end
end

function row = pathPickerRow(parentGrid, rowIdx, colIdx, initialValue, pickMode, filterSpec, popupTitle)
sub = uigridlayout(parentGrid, [1 2]);
sub.Layout.Row = rowIdx; sub.Layout.Column = colIdx;
sub.ColumnWidth = {"1x", 80};
sub.Padding = [0 0 0 0];
sub.ColumnSpacing = 6;

ef = uieditfield(sub, "text", "Value", initialValue);
ef.Layout.Column = 1;

btn = uibutton(sub, "Text", "Browse...");
btn.Layout.Column = 2;
btn.ButtonPushedFcn = @(~,~) browse();

row.EditField = ef;
row.BrowseButton = btn;

    function browse()
        fig = ancestor(sub, "figure");
        lastDir = getappdata(fig, "LastBrowseDir");
        if isempty(lastDir) || strlength(lastDir) == 0
            lastDir = string(pwd);
        end

        currentVal = strtrim(ef.Value);
        switch pickMode
            case "folder"
                if isfolder(currentVal)
                    startDir = currentVal;
                else
                    startDir = lastDir;
                end
                d = uigetdir(startDir, popupTitle);
                if isequal(d, 0), return; end
                ef.Value = d;
                setappdata(fig, "LastBrowseDir", string(d));

            case "file-open"
                if isfolder(currentVal)
                    startPath = currentVal;
                elseif isfile(currentVal)
                    startPath = currentVal;
                else
                    startPath = lastDir;
                end
                [f, p] = uigetfile(char(filterSpec), popupTitle, startPath);
                if isequal(f, 0), return; end
                ef.Value = fullfile(p, f);
                setappdata(fig, "LastBrowseDir", string(p));

            case "file-save"
                if strlength(currentVal) == 0
                    pName = strtrim(nameField.Value);
                    if strlength(pName) == 0, pName = "pipeline"; end
                    currentVal = fullfile(lastDir, pName + ".mat");
                end
                
                [f, p] = uiputfile(char(filterSpec), popupTitle, currentVal);
                if isequal(f, 0), return; end
                ef.Value = fullfile(p, f);
                setappdata(fig, "LastBrowseDir", string(p));
        end
    end
end