function OpenDocumentationSelected(app, event) %#ok<INUSD>
% Opens the tool's documentation. Placeholder URL, to lead to the
% real GitHub wiki / docs site once available.
% NEEDS TOOLBOX CALL
docUrl = "https://github.com/YOUR_ORG/YOUR_REPO/wiki";
try
    web(docUrl, "-browser");
catch ME
    uialert(app.UIFigure, "Could not open documentation: " + ME.message, "Open failed");
end
end
