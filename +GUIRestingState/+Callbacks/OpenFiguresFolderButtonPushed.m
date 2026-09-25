function OpenFiguresFolderButtonPushed(app, event) %#ok<INUSD>
% Opens folder containing pipeline output figures.
figuresPath = fullfile(app.Pipeline.OutputPath, "derivatives", "Figures");
GUIRestingState.Utils.TryOpen(app, string(figuresPath), "figures folder");
end
