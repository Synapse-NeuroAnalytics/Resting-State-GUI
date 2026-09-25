function ExitMenuSelected(app, event) %#ok<INUSD>
% Prompts to save unsaved changes, then closes the app.
choice = uiconfirm(app.UIFigure, "Save the current pipeline before exiting?", ...
    "Exit", "Options", ["Save and exit", "Exit without saving", "Cancel"], ...
    "DefaultOption", 1, "CancelOption", 3);

switch choice
    case "Save and exit"
        GUIRestingState.Callbacks.SavePipelineMenuSelected(app, event);
        delete(app);
    case "Exit without saving"
        delete(app);
    otherwise
        % Cancel - do nothing
end
end