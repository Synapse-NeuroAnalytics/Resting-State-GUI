function Log(message, app)
% Writes timestamped log messages to command window, UI panel, and log file.
arguments
    message (1,1) string
    app = []
end

timestamp = string(datetime("now", "Format", "HH:mm:ss"));
line = "[" + timestamp + "] " + message;
fprintf("%s\n", line);

if isempty(app)
    return
end

% Append to UI execution log
if isprop(app, "LogTextArea") && isvalid(app.LogTextArea)
    existing = app.LogTextArea.Value;
    if isequal(existing, {""}) || isempty(existing)
        existing = {};
    end
    app.LogTextArea.Value = [existing; {char(line)}];
    scroll(app.LogTextArea, "bottom");
end

% Append to log file if configured
if isprop(app, "LogFilePath") && strlength(app.LogFilePath) > 0
    try
        fid = fopen(app.LogFilePath, "a");
        if fid ~= -1
            fprintf(fid, "%s\n", line);
            fclose(fid);
        end
    catch ME
        fprintf("Warning: Could not write to log file (%s)\n", ME.message);
    end
end
end