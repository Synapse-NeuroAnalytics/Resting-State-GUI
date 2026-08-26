function BuildStepRows(app)
% Builds and populates the scrollable grid layout for all pipeline steps.
headerText = struct( ...
    "Import",         "Import Raw Data", ...
    "QualityControl",  "Quality Control", ...
    "Preprocessing",   "Preprocessing");

n = numel(app.Pipeline.Steps);
app.StepHandles = repmat(struct( ...
    "NumberBadge", [], "EnabledCheckbox", [], "ParamControls", struct([]), ...
    "GenFiguresCheckbox", [], "OpenFigFolderButton", [], ...
    "RunOnlyButton", [], "RunFromHereButton", [], "RunToHereButton", []), 1, n);

% Map UI rows to step indices and section headers
rowSpecs = {"master_controls"};   
rowStepIdx = 0;
lastPhase = "";

for i = 1:n
    phase = app.Pipeline.Steps(i).Phase;
    if phase ~= lastPhase
        rowSpecs{end+1} = "header"; %#ok<AGROW>
        rowStepIdx(end+1) = 0; %#ok<AGROW>
        lastPhase = phase;
    end
    rowSpecs{end+1} = "step"; %#ok<AGROW>
    rowStepIdx(end+1) = i; %#ok<AGROW>
end
nRows = numel(rowSpecs);

delete(app.StepsScrollPanel.Children);
app.StepsScrollPanel.Scrollable = "on";

% Compute row heights
rowHeights = cell(1, nRows);
numericHeights = zeros(1, nRows);
for r = 1:nRows
    switch rowSpecs{r}
        case "master_controls"
            numericHeights(r) = 42;
        case "header"
            numericHeights(r) = 40;
        case "step"
            numericHeights(r) = 62;
    end
    rowHeights{r} = numericHeights(r);
end

rowSpacing = 3;
paddingTopBottom = 12;
totalGridHeight = sum(numericHeights) + (nRows - 1) * rowSpacing + paddingTopBottom;

% Scroll panel container setup
scrollPanelPos = app.StepsScrollPanel.Position;
scrollPanelWidth = scrollPanelPos(3);
scrollPanelHeight = scrollPanelPos(4);
containerHeight = max(totalGridHeight, scrollPanelHeight);

initialWidth = max(scrollPanelWidth - 20, 100);
app.StepsScrollPanel.AutoResizeChildren = "off";

gridContainer = uipanel(app.StepsScrollPanel, ...
    "Position", [1, 1, initialWidth, containerHeight], ...
    "BorderType", "none", ...
    "BackgroundColor", app.StepsScrollPanel.BackgroundColor);

app.StepsScrollPanel.SizeChangedFcn = @(~,~) onPanelResized();

    function onPanelResized()
        if isvalid(gridContainer) && isvalid(app.StepsScrollPanel)
            currentWidth = app.StepsScrollPanel.Position(3);
            currentHeight = app.StepsScrollPanel.Position(4);
            
            newContainerHeight = max(totalGridHeight, currentHeight);
            gridContainer.Position(3) = max(currentWidth - 20, 100);
            gridContainer.Position(4) = newContainerHeight;
        end
    end

app.StepsGrid = uigridlayout(gridContainer, [nRows, 1]);
app.StepsGrid.RowHeight = rowHeights;
app.StepsGrid.ColumnWidth = {"1x"};
app.StepsGrid.Padding = [8 8 8 8];
app.StepsGrid.RowSpacing = rowSpacing;
app.StepsGrid.BackgroundColor = app.StepsScrollPanel.BackgroundColor;

% Render elements
for r = 1:nRows
    switch rowSpecs{r}
        case "master_controls"
            banner = uipanel(app.StepsGrid, ...
                "BackgroundColor", app.StepsScrollPanel.BackgroundColor, ...
                "BorderType", "line", ...
                "HighlightColor", [0.70, 0.55, 0.30]);
            banner.Layout.Row = r; 
            banner.Layout.Column = 1;

            bannerGrid = uigridlayout(banner, [1, 3]);
            bannerGrid.ColumnWidth = {"1x", 140, 70};
            bannerGrid.Padding = [8 4 8 4];
            bannerGrid.BackgroundColor = app.StepsScrollPanel.BackgroundColor;

            lbl = uilabel(bannerGrid, "Text", "Global Pipeline Controls:", ...
                "FontWeight", "bold", "FontSize", 12, "FontColor", [0.20 0.14 0.10]);
            lbl.Layout.Column = 1;

            switchLbl = uilabel(bannerGrid, "Text", "Generate All Figures", ...
                "HorizontalAlignment", "right", "FontSize", 11, "FontColor", [0.20 0.14 0.10]);
            switchLbl.Layout.Column = 2;

            masterSwitch = uiswitch(bannerGrid, "slider", "Value", "On");
            masterSwitch.Layout.Column = 3;
            masterSwitch.ValueChangedFcn = @(src, event) GUI.Callbacks.GenAllFiguresChanged(app, event);

            app.GenAllFigsSwitch = masterSwitch;

        case "header"
            idxOfNextStep = rowStepIdx(find(rowStepIdx(r:end) > 0, 1) + r - 1);
            phaseName = app.Pipeline.Steps(idxOfNextStep).Phase;

            headerCell = uigridlayout(app.StepsGrid, [2, 1]);
            headerCell.Layout.Row = r;
            headerCell.Layout.Column = 1;
            headerCell.RowHeight = {"fit", 2};
            headerCell.Padding = [0 0 0 0];
            headerCell.RowSpacing = 3;
            headerCell.BackgroundColor = app.StepsScrollPanel.BackgroundColor;

            lbl = uilabel(headerCell, "Text", headerText.(phaseName), ...
                "FontWeight", "bold", "FontSize", 15, "FontColor", [0.30, 0.17, 0.09]);
            lbl.Layout.Row = 1;

            accentBar = uipanel(headerCell, "BackgroundColor", [0.70, 0.55, 0.30], "BorderType", "none");
            accentBar.Layout.Row = 2;

        case "step"
            i = rowStepIdx(r);
            rowPanel = GUI.UI.BuildOneStepRow(app, i);
            rowPanel.Layout.Row = r; 
            rowPanel.Layout.Column = 1;
    end
end

GUI.UI.RefreshStepRows(app, 1:n);
end