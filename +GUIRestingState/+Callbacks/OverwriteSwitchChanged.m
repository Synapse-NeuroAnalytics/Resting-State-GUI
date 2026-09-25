function OverwriteSwitchChanged(app, event)
% Toggle overwrite parameter.
app.Pipeline.Overwrite = strcmp(event.Value, "On");
GUIRestingState.Utils.Log(sprintf("Overwrite set to %s.", string(event.Value)), app);
end
