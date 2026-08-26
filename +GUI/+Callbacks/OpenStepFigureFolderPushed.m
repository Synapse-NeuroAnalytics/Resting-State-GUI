function OpenStepFigureFolderPushed(app, event, stepIndex) %#ok<INUSD>
% Open output figure folder for an individual step.
step = app.Pipeline.Steps(stepIndex);
folderPath = fullfile(app.Pipeline.OutputPath, "derivatives", "Figures", step.FigureFolder);
GUI.Utils.TryOpen(app, string(folderPath), sprintf("figure folder for step %s", step.ID));
end
