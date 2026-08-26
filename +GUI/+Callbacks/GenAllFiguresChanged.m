function GenAllFiguresChanged(app, event)
% Toggle figure generation globally, with exceptions for:
%   2.2, 3.8, 3.9
%   Disabled steps.
if ischar(event.Value) || isstring(event.Value)
    tf = strcmp(event.Value, 'On');
else
    tf = logical(event.Value);
end

exemptIDs = GUI.Utils.NonDataChangingStepIDs();

if ~isempty(app.Pipeline) && ~isempty(app.Pipeline.Steps)
    for i = 1:numel(app.Pipeline.Steps)
        st = app.Pipeline.Steps(i);
        if any(strcmp(st.ID, exemptIDs)) || ~st.Enabled
            continue
        end
        app.Pipeline.Steps(i).GenerateFigures = tf;
    end
end

if ~isempty(app.StepHandles)
    for i = 1:numel(app.StepHandles)
        if i <= numel(app.Pipeline.Steps)
            st = app.Pipeline.Steps(i);
            if any(strcmp(st.ID, exemptIDs)) || ~st.Enabled
                continue
            end
        end
        if isfield(app.StepHandles(i), 'GenFiguresCheckbox') && ...
                ~isempty(app.StepHandles(i).GenFiguresCheckbox) && ...
                isvalid(app.StepHandles(i).GenFiguresCheckbox)
            app.StepHandles(i).GenFiguresCheckbox.Value = tf;
        end
    end
end
end
