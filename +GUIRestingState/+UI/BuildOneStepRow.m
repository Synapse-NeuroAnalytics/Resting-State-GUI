function rowGrid = BuildOneStepRow(app, i)
% Constructs UI layout for a single pipeline step row.
s = app.Pipeline.Steps(i);

rowGrid = uigridlayout(app.StepsGrid, [1, 5]);
rowGrid.ColumnWidth = {38, 122, "1x", 108, 172};
rowGrid.Padding = [2 4 2 4];
rowGrid.ColumnSpacing = 8;
rowGrid.BackgroundColor = app.StepsScrollPanel.BackgroundColor;

% ID badge
badgePanel = uipanel(rowGrid, "BorderType", "line", "HighlightColor", [0.28, 0.16, 0.09], ...
    "BackgroundColor", app.PhaseColors.(s.Phase));
badgePanel.Layout.Row = 1; badgePanel.Layout.Column = 1;
badgeGrid = uigridlayout(badgePanel, [1, 1]);
badgeGrid.Padding = [0 0 0 0];
badgeGrid.BackgroundColor = app.PhaseColors.(s.Phase);
badge = uilabel(badgeGrid, "Text", s.ID, "FontWeight", "bold", "FontSize", 11, ...
    "HorizontalAlignment", "center", "FontColor", "black", ...
    "BackgroundColor", app.PhaseColors.(s.Phase));

% Name and enabled state
nameGrid = uigridlayout(rowGrid, [2 1]);
nameGrid.Layout.Row = 1; nameGrid.Layout.Column = 2;
nameGrid.Padding = [0 0 0 0]; nameGrid.RowSpacing = 1;
nameGrid.BackgroundColor = app.StepsScrollPanel.BackgroundColor;
nameLbl = uilabel(nameGrid, "Text", s.Name, "FontWeight", "bold", "WordWrap", "on", "FontSize", 11, ...
    "FontColor", [0.20 0.14 0.10]);
nameLbl.Layout.Row = 1;
enabledCb = uicheckbox(nameGrid, "Text", "Enabled", "Value", s.Enabled, "FontSize", 11, ...
    "FontColor", [0.20 0.14 0.10]);
enabledCb.Layout.Row = 2;
if s.Mandatory
    enabledCb.Enable = "off";
    enabledCb.Text = "Always enabled";
    enabledCb.Tooltip = "This step is mandatory and cannot be disabled.";
else
    enabledCb.Tooltip = "Toggle whether this step runs.";
end
enabledCb.ValueChangedFcn = @(src, event) GUIRestingState.Callbacks.StepEnabledChanged(app, event, i);

% Dynamic parameter inputs
numParams = numel(s.Parameters);
paramGrid = uigridlayout(rowGrid, [1, max(numParams, 1) + (numParams == 1)]);
paramGrid.Layout.Row = 1; paramGrid.Layout.Column = 3;
paramGrid.Padding = [0 0 0 0]; paramGrid.ColumnSpacing = 8;
paramGrid.BackgroundColor = app.StepsScrollPanel.BackgroundColor;

if numParams > 0
    colWidths = cell(1, numParams);
    for p = 1:numParams
        if s.Parameters(p).Type == "file"
            colWidths{p} = "2x";
        else
            colWidths{p} = "1x";
        end
    end
    if numParams == 1 && s.Parameters(1).Type ~= "file"
        colWidths{1} = 120;     
        colWidths{end+1} = "1x";
    end
    paramGrid.ColumnWidth = colWidths;
end

paramControls = struct("Name", {}, "Handle", {});
if isempty(s.Parameters)
    uilabel(paramGrid, "Text", "(no parameters)", "FontColor", [0.55 0.50 0.45], "FontSize", 11);
else
    for p = 1:numParams
        param = s.Parameters(p);
        cell_ = uigridlayout(paramGrid, [2 1]);
        cell_.Layout.Column = p;
        cell_.Padding = [0 0 0 0]; cell_.RowSpacing = 2;
        cell_.RowHeight = {"fit", "1x"};
        cell_.BackgroundColor = app.StepsScrollPanel.BackgroundColor;
        
        plbl = uilabel(cell_, "Text", param.Label, "FontSize", 10, "WordWrap", "on", ...
            "FontColor", [0.20 0.14 0.10]);
        plbl.Layout.Row = 1;
        plbl.Tooltip = param.Description;

        switch param.Type
            case "numeric"
                ctrl = uieditfield(cell_, "numeric", "Value", ...
                    fallbackNumeric(param.Value, param.Default), "Limits", [-Inf Inf]);
                ctrl.Layout.Row = 2;
                ctrl.BackgroundColor = app.OtherColors.InputBackground;
                ctrl.FontColor = [0.20 0.14 0.10];
            case "logical"
                ctrl = uicheckbox(cell_, "Text", "", "Value", logical(param.Value));
                ctrl.Layout.Row = 2;
                ctrl.FontColor = [0.20 0.14 0.10];
            case "dropdown"
                ctrl = uidropdown(cell_, ...
                    "Items", cellfun(@char, param.Options, "UniformOutput", false), ...
                    "Value", char(param.Value));
                ctrl.Layout.Row = 2;
                ctrl.BackgroundColor = app.OtherColors.InputBackground;
                ctrl.FontColor = [0.20 0.14 0.10];
            case "file"
                fileGrid = uigridlayout(cell_, [1 2]);
                fileGrid.Layout.Row = 2;
                fileGrid.Layout.Column = 1;
                fileGrid.RowHeight = {22};
                fileGrid.ColumnWidth = {"1x", 80};
                fileGrid.Padding = [0 0 0 0];
                fileGrid.ColumnSpacing = 4;
                fileGrid.BackgroundColor = app.StepsScrollPanel.BackgroundColor;
                
                ef = uieditfield(fileGrid, "text", "Value", char(param.Value));
                ef.Layout.Row = 1; ef.Layout.Column = 1;
                ef.FontSize = 10;
                ef.Tooltip = char(param.Value);
                ef.BackgroundColor = app.OtherColors.InputBackground;
                ef.FontColor = [0.20 0.14 0.10];
                
                btn = uibutton(fileGrid, "Text", "Browse", "FontWeight", "bold", "FontSize", 10);
                btn.Layout.Row = 1; btn.Layout.Column = 2;
                btn.ButtonPushedFcn = @(src, event) browseForFile(ef, param.Options);
                btn.BackgroundColor = app.StepsScrollPanel.BackgroundColor;
                btn.FontColor = [0.20 0.14 0.10];
                ctrl = ef;
            otherwise
                ctrl = uieditfield(cell_, "text", "Value", char(string(param.Value)));
                ctrl.Layout.Row = 2;
                ctrl.BackgroundColor = app.OtherColors.InputBackground;
                ctrl.FontColor = [0.20 0.14 0.10];
        end
        ctrl.Tooltip = param.Description;
        ctrl.ValueChangedFcn = @(src, event) GUIRestingState.Callbacks.ParameterValueChanged(app, event, i, p);
        paramControls(end+1) = struct("Name", param.Name, "Handle", ctrl); %#ok<AGROW>
    end
end

% Figure controls
figGrid = uigridlayout(rowGrid, [2 1]);
figGrid.Layout.Row = 1; figGrid.Layout.Column = 4;
figGrid.Padding = [0 0 0 0];
figGrid.RowSpacing = 4;
figGrid.RowHeight = {"fit", 22};
figGrid.BackgroundColor = app.StepsScrollPanel.BackgroundColor;

genFigCb = uicheckbox(figGrid, "Text", "generate figures", "Value", s.GenerateFigures, ...
    "FontSize", 10, "Tooltip", "Generating figures can slow down processing.", ...
    "FontColor", [0.20 0.14 0.10]);
genFigCb.Layout.Row = 1; genFigCb.Layout.Column = 1;
genFigCb.ValueChangedFcn = @(src, event) GUIRestingState.Callbacks.GenerateFiguresChanged(app, event, i);

openFigBtn = uibutton(figGrid, "Text", "open figure folder", "FontSize", 10, ...
    "BackgroundColor", [0.498, 0.498, 0.498], "FontColor", "white", ...
    "ButtonPushedFcn", @(src, event) GUIRestingState.Callbacks.OpenStepFigureFolderPushed(app, event, i));
openFigBtn.Layout.Row = 2; openFigBtn.Layout.Column = 1;

% Execution buttons - three depths of one warm terracotta hue
runGrid = uigridlayout(rowGrid, [1 3]);
runGrid.Layout.Row = 1; runGrid.Layout.Column = 5;
runGrid.Padding = [0 0 0 0]; runGrid.ColumnSpacing = 4;
runGrid.BackgroundColor = app.StepsScrollPanel.BackgroundColor;

runOnlyBtn = uibutton(runGrid, "Text", sprintf("run\nonly"), "FontSize", 10, ...
    "BackgroundColor", [0.706, 0.722, 0.604], "FontColor", [0.32 0.15 0.07], ...
    "ButtonPushedFcn", @(src, event) GUIRestingState.Callbacks.RunOnlyPushed(app, event, i));

runToBtn = uibutton(runGrid, "Text", sprintf("run to\nhere"), "FontSize", 10, ...
    "BackgroundColor", [0.706, 0.722, 0.604], "FontColor", [0.32 0.15 0.07], ...
    "ButtonPushedFcn", @(src, event) GUIRestingState.Callbacks.RunToHerePushed(app, event, i));

runFromBtn = uibutton(runGrid, "Text", sprintf("run from\nhere"), "FontSize", 10, ...
    "BackgroundColor", [0.706, 0.722, 0.604], "FontColor", [0.32 0.15 0.07], ...
    "ButtonPushedFcn", @(src, event) GUIRestingState.Callbacks.RunFromHerePushed(app, event, i));

% Store step UI handles
app.StepHandles(i) = struct( ...
    "NumberBadge", badge, "EnabledCheckbox", enabledCb, "ParamControls", paramControls, ...
    "GenFiguresCheckbox", genFigCb, "OpenFigFolderButton", openFigBtn, ...
    "RunOnlyButton", runOnlyBtn, "RunFromHereButton", runFromBtn, "RunToHereButton", runToBtn);

    function browseForFile(ef, options)
        if (nargin < 2) || isempty(options)
            [f, folder] = uigetfile("*.m", "Select function file");
        else
            [f, folder] = uigetfile(options{1}.FileSelectType, options{1}.FileSelectText);
        end
        if ~isequal(f, 0)
            fullP = fullfile(folder, f);
            ef.Value = fullP;
            ef.Tooltip = fullP;
            ef.ValueChangedFcn(ef, struct("Source", ef, "Value", fullP));
        end
    end
end

function v = fallbackNumeric(val, defaultVal)
    if nargin < 2, defaultVal = 0; end
    v = extractValidScalar(val);
    if isnan(v), v = extractValidScalar(defaultVal); end
    if isnan(v), v = 0; end
end

function s = extractValidScalar(x)
    if isnumeric(x) && isscalar(x) && ~isnan(x)
        s = double(x);
    elseif (ischar(x) || isstring(x)) && ~isempty(x)
        s = str2double(x);
    else
        s = NaN;
    end
end

function c = blendColor(base, accent, alpha)
% Blends accent into base by alpha (0-1).
arguments
    base (1,3) double
    accent (1,3) double
    alpha (1,1) double
end
c = base .* (1 - alpha) + accent .* alpha;
end
