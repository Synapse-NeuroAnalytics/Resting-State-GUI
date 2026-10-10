function OpenGitHubSelected(app, event) %#ok<INUSD>
% Opens the tool's GitHub page
docUrl = "https://github.com/Synapse-NeuroAnalytics/Resting-State-GUI";
try
    web(docUrl, "-browser");
catch ME
    uialert(app.UIFigure, "Could not open GitHub: " + ME.message, "Open failed");
end
end
