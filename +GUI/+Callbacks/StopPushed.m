function StopPushed(app, event) %#ok<INUSD>
% Requests that the current run halt after the in-progress step finishes.
% Does not interrupt a step mid-execution (MATLAB can't preempt a running
% call) - it's picked up at the next checkpoint in Pipeline.RunSteps.
if ~app.IsRunning
    GUI.Utils.Log("Stop requested, but no run is currently in progress.", app);
    return
end

app.StopRequested = true;
app.StopButton.Enable = "off";  % avoid duplicate requests while it winds down
GUI.Utils.Log("Stopping run after the current step finishes...", app);
end
