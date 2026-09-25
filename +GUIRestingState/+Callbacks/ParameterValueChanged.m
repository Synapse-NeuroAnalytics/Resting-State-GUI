function ParameterValueChanged(app, event, stepIndex, paramIndex)
% Updates the stored parameter value. If a value is changed,
% it marks the step and all downstream steps as needing a rerun.
currentStep = app.Pipeline.Steps(stepIndex);
param = currentStep.Parameters(paramIndex);
newValue = event.Value;

[isValid, errorMsg] = GUIRestingState.Utils.ValidateParam(newValue, param.Validation, currentStep);
if ~isValid
    uialert(ancestor(event.Source, "figure"), errorMsg, "Invalid Parameter Value", "Icon", "warning");
    if isprop(event, "PreviousValue") && ~isempty(event.PreviousValue)
        event.Source.Value = event.PreviousValue;
    else
        event.Source.Value = param.Default;
    end
    return;
end

app.Pipeline.Steps(stepIndex).Parameters(paramIndex).Value = newValue;
param = app.Pipeline.Steps(stepIndex).Parameters(paramIndex);

GUIRestingState.Utils.Log(sprintf("Step %s: parameter '%s' changed to %s.", ...
    app.Pipeline.Steps(stepIndex).ID, param.Name, formatValue(newValue)), app);

GUIRestingState.Utils.MarkDownstreamDirty(app);

if strlength(app.Pipeline.PipelinePath) > 0
    app.Pipeline.Save(app.Pipeline.PipelinePath);
end
end

function s = formatValue(v)
if islogical(v) || isnumeric(v)
    s = string(v);
else
    s = '"' + string(v) + '"';
end
end