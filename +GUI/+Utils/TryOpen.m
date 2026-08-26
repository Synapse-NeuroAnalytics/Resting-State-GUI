function TryOpen(app, pathToOpen, label)
% Opens path and alerts user on failure.
arguments
    app
    pathToOpen (1,1) string
    label (1,1) string = "path"
end

try
    GUI.Utils.OpenPath(pathToOpen);
catch ME
    uialert(app.UIFigure, sprintf("Could not open %s: %s", label, ME.message), "Open failed");
end
end