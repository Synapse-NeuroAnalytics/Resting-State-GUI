function OpenLogFilePushed(app, event) %#ok<INUSD>
% Opens the duplicate log text file. If none has been configured yet,
% create one in the pipeline's output folder.
if strlength(app.LogFilePath) == 0
    if strlength(app.Pipeline.OutputPath) == 0
        uialert(app.UIFigure, "Set an output folder before creating a log file.", "No output folder");
        return
    end
    logDir = fullfile(app.Pipeline.OutputPath, "derivatives");
    if ~isfolder(logDir)
        mkdir(logDir);
    end
    app.LogFilePath = string(fullfile(logDir, "execution_log.txt"));
    if ~isfile(app.LogFilePath)
        fclose(fopen(app.LogFilePath, "w"));
    end
end

GUI.Utils.TryOpen(app, app.LogFilePath, "log file");
end
