function OpenSpreadsheetPushed(app, event) %#ok<INUSD>
% Open input parameter spreadsheet, if existing.
GUI.Utils.TryOpen(app, app.Pipeline.SpreadsheetPath, "dataset spreadsheet");
end
