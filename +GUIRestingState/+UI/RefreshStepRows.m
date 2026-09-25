function RefreshStepRows(app, indices)
% Re-applies badge color, enabled-state, and lock states to specified step rows.
arguments
    app
    indices (1,:) double
end

exemptIDs = GUIRestingState.Utils.NonDataChangingStepIDs();

for i = indices
    if i < 1 || i > numel(app.StepHandles)
        continue
    end

    h = app.StepHandles(i);
    s = app.Pipeline.Steps(i);
    baseColor = app.PhaseColors.(s.Phase);

    if s.Enabled && s.NeedsRerun
        h.NumberBadge.BackgroundColor = app.DirtyColor;
    else
        h.NumberBadge.BackgroundColor = baseColor;
    end

    h.EnabledCheckbox.Value = s.Enabled;
    if s.Mandatory
        h.EnabledCheckbox.Enable = "off";
        h.EnabledCheckbox.Text = "Always enabled";
    else
        h.EnabledCheckbox.Enable = "on";
        h.EnabledCheckbox.Text = "Enabled";
    end

    if ~isempty(h.ParamControls)
        for pc = 1:numel(h.ParamControls)
            ctrl = h.ParamControls(pc).Handle;
            if isvalid(ctrl)
                ctrl.Enable = s.Enabled;
            end
        end
    end

    if ~isempty(h.GenFiguresCheckbox) && isvalid(h.GenFiguresCheckbox)
        if any(strcmp(s.ID, exemptIDs))
            h.GenFiguresCheckbox.Value = true;
            h.GenFiguresCheckbox.Enable = "off";
            h.GenFiguresCheckbox.Tooltip = "Figure generation cannot be disabled for this step.";
        elseif ~s.Enabled
            h.GenFiguresCheckbox.Value = false;
            h.GenFiguresCheckbox.Enable = "off";
            h.GenFiguresCheckbox.Tooltip = "Locked while this step is disabled.";
        else
            h.GenFiguresCheckbox.Value = s.GenerateFigures;
            h.GenFiguresCheckbox.Enable = "on";
            h.GenFiguresCheckbox.Tooltip = "Generating figures slows down processing.";
        end
    end
end
end
