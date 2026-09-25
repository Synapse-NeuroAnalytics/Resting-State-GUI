function OpenRawFolderButtonPushed(app, event) %#ok<INUSD>
% Opens input folder containing raw data.
GUIRestingState.Utils.TryOpen(app, app.Pipeline.RawDataPath, "raw data folder");
end
