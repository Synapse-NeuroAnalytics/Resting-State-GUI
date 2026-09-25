classdef Pipeline < handle
    % Pipeline configuration and execution engine.

    properties
        % Dataset paths
        TaskName            string = "rest"
        PipelineName        string = ""
        PipelinePath        string = ""
        SpreadsheetPath     string = ""
        RawDataPath         string = ""
        OutputPath          string = ""

        % Global configuration
        Overwrite           logical = true

        % Pipeline steps
        Steps               struct = struct([])

        % Metadata
        Version             string = "0.1.0"
        UIState             struct = struct("Position", [], "Size", [])
    end

    properties (Constant)
        TEST_MODE = false
    end

    methods
        function obj = Pipeline()
            % Initializes steps from central step configuration.
            obj.Steps = GUIRestingState.StepConfig();
        end

        function ClearSteps(obj)
            % Removes all steps from the pipeline.
            obj.Steps = GUIRestingState.EmptyStep(0);
        end

        function AddStep(obj, step)
            % Appends a step struct to the pipeline.
            arguments
                obj
                step (1,1) struct
            end

            if isempty(obj.Steps)
                obj.Steps = step;
            else
                obj.Steps(end+1) = step;
            end
        end

        function RunSteps(obj, indices, app)
            % Runs processing steps sequentially by index.
            arguments
                obj
                indices (1,:) double
                app = []
            end

            % Stop/Continue bookkeeping - reset flag, lock the Run buttons,
            % and guarantee everything is restored even if a step errors
            % or the user stops partway through.
            hasStopSupport = ~isempty(app) && isprop(app, 'IsRunning');
            if hasStopSupport
                app.StopRequested = false;
                app.IsRunning = true;
                GUIRestingState.Utils.SetRunControlsEnabled(app, false);
            end
            cleanupObj = onCleanup(@() localFinishRun(app, hasStopSupport)); %#ok<NASGU>

            % Mark every enabled step about to run as "queued" (orange) so
            % progress is visible on the step badges immediately, rather
            % than only via the log. Each step reverts to its normal/dirty
            % color as it finishes (see RefreshStepRows call at the end of
            % the loop below).
            if ~isempty(app) && isvalid(app) && isprop(app, 'StepHandles') && ~isempty(app.StepHandles)
                for k = 1:numel(indices)
                    idx = indices(k);
                    if idx < 1 || idx > numel(obj.Steps) || idx > numel(app.StepHandles)
                        continue
                    end
                    if ~obj.Steps(idx).Enabled
                        continue
                    end
                    h = app.StepHandles(idx);
                    if ~isempty(h.NumberBadge) && isvalid(h.NumberBadge)
                        h.NumberBadge.BackgroundColor = app.OtherColors.RunningColor;
                    end
                end
                drawnow;
            end

            % Initialize fNIRS-Preprocessing Pipeline (unless GUIRestingState.Pipeline.TEST_MODE)
            if ~GUIRestingState.Pipeline.TEST_MODE
                pipeline = Pipeline;
                pipeline.Name          = obj.PipelineName;
                pipeline.FolderRaw     = obj.RawDataPath;
                pipeline.FolderOut     = obj.OutputPath;
                pipeline.FilepathTable = obj.SpreadsheetPath;
                pipeline.TaskName      = obj.TaskName;
                pipeline.Overwrite     = obj.Overwrite;
    
                % Create full pipeline (needed to determine full suffix for inputs)
                stepToPipelineMapping = nan(1, numel(obj.Steps));
                for idx = 1:numel(obj.Steps)
                    % Skip if disabled
                    if ~obj.Steps(idx).Enabled
                        continue
                    end
                    
                    % create PipelineStep
                    step = obj.Steps(idx).Function();
    
                    % apply parameters
                    for param = obj.Steps(idx).Parameters(:)'
                        value = param.Value;
    
                        % exceptions
                        switch param.Name
                            case "CustomFunction"
                                if ischar(value)
                                    value = string(value);
                                end
                                if value.strlength < 1
                                    value = missing;
                                else
                                    value = getFunctionHandleFromPath(value);
                                end
    
                            case "ParallelPools"
                                if value == "OFF"
                                    value = 0;
                                else
                                    value = str2num(value);
                                end
    
                            case "LowCutoff"
                                % combined below
                                continue
    
                            case "HighCutoff"
                                % combine into passband
                                select = find( [obj.Steps(idx).Parameters.Name] == "LowCutoff" );
                                step.Passband = [obj.Steps(idx).Parameters(select).Value , value];
                                continue
    
                            case {"IgnoreChannelsBelowRatioClean" , "ExcludeChannelsBelowRatioClean"}
                                value = value / 100; % pct to ratio
    
                            case {"MinShortChannels" , "MinLongChannels" , "MinDurationSeconds"}
                                % empty for 0?
                                if isempty(value)
                                    value = 0;
                                end

                            case "SensitivityPrecalcPath"
                                if isempty(value)
                                    % use default if not entered
                                    continue
                                end
    
                        end

                        if param.Validation == "seeds"
                            if ~isempty(value)
                                value = str2num(value);
                                value(value < 1) = [];
                                value(value ~= round(value)) = [];
                            end
                        end
    
                        step.(param.Name) = value;
                    end
    
                    % figure info
                    step.SubfolderFigures = obj.Steps(idx).FigureFolder;
                    step.GenerateFigure   = obj.Steps(idx).GenerateFigures;
                    if app.HighResCheckbox.Value
                        step.FigureResolution = 175;
                    else
                        step.FigureResolution = 75;
                    end
    
                    % add step
                    pipeline.AddStep(step);

                    % store lookup
                    stepToPipelineMapping(idx) = pipeline.countSteps;
                end
            end

            wasStopped = false;
            for k = 1:numel(indices)
                if hasStopSupport && app.StopRequested
                    GUIRestingState.Utils.Log(sprintf("Run stopped by user before step %s.", ...
                        obj.Steps(indices(k)).ID), app);
                    wasStopped = true;
                    break
                end

                idx = indices(k);
                s = obj.Steps(idx);

                % Helps mark enabled/disabled steps
                obj.Steps(idx).LastRunEnabled = s.Enabled;

                if ~s.Enabled
                    GUIRestingState.Utils.Log(sprintf("Skipping step %s (disabled)", s.Name), app);
                    drawnow;
                    continue
                end

                GUIRestingState.Utils.Log(sprintf("Running step %s (%s)...", s.ID, s.Name), app);
                drawnow;  % flush log/badge updates to screen before the (possibly long) step runs

                % run the toolbox function
                if ~GUIRestingState.Pipeline.TEST_MODE
                    pipeline.RunIndex(stepToPipelineMapping(idx));
                end

                for p = 1:numel(s.Parameters)
                    obj.Steps(idx).Parameters(p).LastRunValue = s.Parameters(p).Value;
                end

                GUIRestingState.Utils.Log(sprintf("Finished step %s", s.ID), app);

                GUIRestingState.Utils.MarkDownstreamDirty(app);
                drawnow;  % repaint badge color / log immediately, don't wait for the whole run to finish
            end

            if ~wasStopped
                GUIRestingState.Utils.Log("All selected steps have completed.", app);
            end
        end

        function Save(obj, filepath)
            % Saves pipeline configuration to a .mat file.
            arguments
                obj
                filepath (1,1) string
            end

            pipeline = obj; %#ok<NASGU>
            save(filepath, "pipeline", "-v7.3");
            GUIRestingState.Utils.Log(sprintf("Pipeline saved to %s", filepath));
        end
    end

    methods (Static)
        function obj = Load(filepath)
            % Loads pipeline configuration from a .mat file.
            arguments
                filepath (1,1) string
            end

            data = load(filepath, "pipeline");
            obj = data.pipeline;
        end

        function paths = RequiredPaths(obj)
            % Returns struct of required pipeline paths.
            arguments
                obj (1,1) GUIRestingState.Pipeline
            end

            paths = struct( ...
                "PipelinePath",    obj.PipelinePath, ...
                "SpreadsheetPath", obj.SpreadsheetPath, ...
                "RawDataPath",     obj.RawDataPath, ...
                "OutputPath",      obj.OutputPath);
        end
    end
end

function localFinishRun(app, hasStopSupport)
% Restores run-control button states once RunSteps exits, whether it
% finished normally, was stopped by the user, or errored out.
if ~hasStopSupport || isempty(app) || ~isvalid(app)
    return
end
app.IsRunning = false;
GUIRestingState.Utils.SetRunControlsEnabled(app, true);
end