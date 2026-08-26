function OpenOutputFolderButtonPushed(app, event) %#ok<INUSD>
% Opens pipeline output folder.
GUI.Utils.TryOpen(app, app.Pipeline.OutputPath, "output folder");
end
