function steps = StepConfig()
% Configures all preprocessing steps, validation rules, defaults, and figure output folders.
%
% The main App builds the entire step list UI by looping over this
% struct array, so adding/removing/reordering a step in a future version
% is a matter of editing this one function, and the base UI does not need to
% change.
%
% NEEDS TOOLBOX CALL:
% For parameters to be read from the spreadsheet, they can be accessed through
% the spreadsheet path contained in the pipeline handle.

steps = GUI.EmptyStep(0);


%% Phase 1: Import Raw Data
% SPREADSHEET READ: Participant head sizes
steps(end+1) = step("1.1", "Import", "Import", true, ...
    "1-1_Import", [
    param("ScaleToHeadSize", "Scale channel distances to head size", "logical", "none", true, {}, ...
        "If true, channel distances are scaled using each participant's head size.")
    param("CustomFunction", "Custom import function (.m)", "file", "none", "", {}, ...
        "Optional project-specific .m function called on each dataset during import.")
    ], "ImportRaw");

steps(end+1) = step("1.2", "Verify Montage", "Import", true, ...
    "1-2_Verify", GUI.EmptyParam(0), "VerifyMontages");


%% Phase 2: Quality Control
% SPREADSHEET READ: IQR values
steps(end+1) = step("2.1", "Motion Correction (TDDR + Wavelet)", "QualityControl", false, ...
    "2-1_QC_Motion-Correction", [
    param("iqrDefault", "Default iqr", "numeric", "positive", 1.2, {}, "")
    ], "QCMotionCorrection");

steps(end+1) = step("2.2", "Identify Cardiac Ranges", "QualityControl", false, ...
    "2-2_QC_Cardiac", [
    param("Normalize", "Normalize", "logical", "none", true, {}, ...
        "Divides each signal's power by its standard deviation, reducing weight of noisy channels.", true, false)
    param("AverageChannels", "Average across signals", "logical", "none", true, {}, ...
        "Averages across all signals to display one line instead of several overlapping lines.", true, false)
    ], "CardiacFigure");

% SPREADSHEET READ: Cardiac ranges
steps(end+1) = step("2.3", "Calculate Quality Metrics (SCI/PSP)", "QualityControl", true, ...
    "2-3_QC_SCI-PSP", [
    param("WindowSeconds", "Window duration (s)", "numeric", "positive", 3, {}, ...
        "Any positive value. Sliding window length used to compute SCI and PSP.")
    param("ParallelPools", "Number of parallel pools", "dropdown", "none", "OFF", {"OFF","2","4","8","12","16","20"}, ...
        "Number of parallel workers to use. OFF disables parallelization.", false)
    ], "QCCalculate");

steps(end+1) = step("2.4", "Trim to Cleanest Segment", "QualityControl", false, ...
    "2-4_QC_Cleanest-Segment", [
    param("SegmentSeconds", "Segment duration (s)", "numeric", "positive", 300, {}, ...
        "Any positive value. Duration of the segment to select in seconds.")
    param("SCIThreshold", "SCI threshold", "numeric", "range_0_1", 0.6, {}, "Range 0-1.")
    param("PSPThreshold", "PSP threshold", "numeric", "range_0_1", 0.1, {}, "Range 0-1.")
    param("IgnoreChannelsBelowRatioClean", "Ignore channels with < X% clean samples", "numeric", "range_0_100", 30, {}, "Range 0-100%.")
    ], "QCTrimSegment");

steps(end+1) = step("2.5", "Channel Exclusion", "QualityControl", false, ...
    "2-5_QC_Channel-Exclusion", [
    param("SCIThreshold", "SCI threshold", "numeric", "range_0_1", 0.6, {}, "Range 0-1.")
    param("PSPThreshold", "PSP threshold", "numeric", "range_0_1", 0.1, {}, "Range 0-1.")
    param("ExcludeChannelsBelowRatioClean", "Exclude channels with < X% clean samples", "numeric", "range_0_100", 60, {}, "Range 0-100%.")
    param("tSNRThreshold", "tSNR threshold", "numeric", "positive", 1.5, {}, "Any positive value. Channels below this tSNR are excluded.")
    ], "QCExcludeChannels");


%% Phase 3: Preprocessing
steps(end+1) = step("3.1", "Optical Density", "Preprocessing", true, ...
    "3-1_Optical-Density", GUI.EmptyParam(0), "OpticalDensity");

steps(end+1) = step("3.2", "Temporal Derivative Distribution Repair", "Preprocessing", false, ...
    "3-2_TDDR", GUI.EmptyParam(0), "TDDR");

% SPREADSHEET READ: IQR values
steps(end+1) = step("3.3", "Wavelet Filter", "Preprocessing", false, ...
    "3-3_Wavelet-Filter", [
    param("iqrDefault", "Default iqr", "numeric", "positive", 1.2, {}, "")
    ], "WaveletFilter");

% SPREADSHEET READ: Participant ages
steps(end+1) = step("3.4", "Modified Beer-Lambert Law", "Preprocessing", true, ...
    "3-4_MBLL", [
    param("AdjustForAge", "Adjust PPF for age", "logical", "none", true, {}, ...
        "Adjusts the partial pathlength factor using each participant's age.")
    ], "MBLL");

steps(end+1) = step("3.5", "Bandpass Filter", "Preprocessing", false, ...
    "3-5_Bandpass", [
    param("LowCutoff", "Passband lower limit (Hz)", "numeric", "positive", 0.009, {}, "Any positive value.")
    param("HighCutoff", "Passband upper limit (Hz)", "numeric", "bandpass_high", 0.08, {}, ...
        "Any positive value greater than the lower limit.")
    ], "Bandpass");

steps(end+1) = step("3.6", "Short Channel Regression", "Preprocessing", false, ...
    "3-6_SDC-Regression", [
    param("MaxComponents", "Maximum number of components", "numeric", "positive_int", 6, {}, "Any positive integer.")
    param("IndependentOxyDeoxy", "Process oxy and deoxy independently", "logical", "none", false, {}, "")
    param("ParallelPools", "Number of parallel pools", "dropdown", "none", "OFF", {"OFF","2","4","8","12","16","20"}, ...
    "Number of parallel workers to use. OFF disables parallelization.", false)
    ], "SDCRegress");

steps(end+1) = step("3.7", "Calculate Total Haemoglobin", "Preprocessing", true, ...
    "3-7_HbT", GUI.EmptyParam(0), "HbT");

steps(end+1) = step("3.8", "Summary Figure", "Preprocessing", false, ...
    "3-8_Summary", GUI.EmptyParam(0), "SummaryFigure");

steps(end+1) = step("3.9", "Connectivity", "Preprocessing", true, ...
    "3-9_Connectivity", [
    param("Robust", "Use Robust Correlation", "logical", "none", false, {}, "Use robust correlation based on Shevlyakov and Smirnov (2011). Much slower than the default method, but may be desired for final analyses.")
    param("FigureZThresh", "Figure Z-Threshold", "numeric", "positive", 0.5, {}, "Any positive value.", false, false)
    param("FigurepThresh", "Figure p-Threshold", "numeric", "range_0_1", 1, {}, "Range 0-1.", false, false)
    param("FigureqThresh", "Figure q-Threshold", "numeric", "range_0_1", 0.01, {}, "Range 0-1.", false, false)
    ], "Connectivity");

steps(end+1) = step("3.10", "Group Connectivity: Select Datasets", "Preprocessing", true, ...
    "3-10_Connectivity-Group", [
    param("MinShortChannels", "Min short channels", "numeric", "non_negative_int", 0, {}, "")
    param("MinLongChannels", "Min long channels", "numeric", "non_negative_int", 0, {}, "")
    param("MinDurationSeconds", "Min duration (s)", "numeric", "positive", 300, {}, "")
    param("FigureZThresh", "Figure Z-Threshold", "numeric", "positive", 0.5, {}, "Any positive value.", false, false)
    param("FigurepThresh", "Figure p-Threshold", "numeric", "range_0_1", 1, {}, "Range 0-1.", false, false)
    param("FigureqThresh", "Figure q-Threshold", "numeric", "range_0_1", 1, {}, "Range 0-1.", false, false)
    ], "ConnectivityGroup");

steps(end+1) = step("3.11", "Group Connectivity: Figures", "Preprocessing", false, ...
    "3-11_Connectivity-Group-Seed", [
    param("SensitivityPrecalcPath", "Precalculated Sensitivity Profile (.mat)", "file", "none", '', {struct(FileSelectType="*.mat", FileSelectText="Select precalculated sensitivity file")}, "Leave empty for example data")
    param("DrawChannelLines", "Draw channel lines", "logical", "none", false, {}, "", false, false)
    param("SeedChannelIndices", "Seeds", "", "seeds", [], {}, "Empty or array of positive integers", false, false)
    ], "ConnectivityGroupSeed");

    function s = step(id, name, phase, mandatory, figFolder, parameters, fcn)
        s = GUI.EmptyStep(1);
        s.ID = id;
        s.Name = name;
        s.Phase = phase;
        s.Mandatory = mandatory;
        s.Enabled = true;
        s.LastRunEnabled = true;
        s.GenerateFigures = true;
        s.FigureFolder = figFolder;
        s.NeedsRerun = false;
        s.Function = eval("@PipelineSteps." + fcn);
        if isempty(parameters)
            s.Parameters = GUI.EmptyParam(0);
        else
            s.Parameters = parameters;
        end
    end

    function p = param(name, label, type, validation, value, options, description, marksDirty, propagatesDirty)
        if nargin < 8
            marksDirty = true;
        end
        if nargin < 9
            propagatesDirty = marksDirty;
        end
        p = GUI.EmptyParam(1);
        p.Name = name;
        p.Label = label;
        p.Type = type;
        p.Validation = validation;
        p.Value = value;
        p.Default = value;
        p.Options = options;
        p.Description = description;
        p.MarksDirty = marksDirty;
        p.PropagatesDirty = propagatesDirty;
        p.LastRunValue = value;
    end
end