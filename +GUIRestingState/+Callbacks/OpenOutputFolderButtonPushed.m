function OpenOutputFolderButtonPushed(app, event) %#ok<INUSD>
% Opens pipeline output folder.
GUIRestingState.Utils.TryOpen(app, app.Pipeline.OutputPath, "output folder");
end
