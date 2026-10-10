function OpenSurfNIRSSelected(app, event)
try
    sn = SurfNIRS;
    sn.SessionInfo.Data.ImportBIDS_AnalyzIR_nirs_core_Data(app.Pipeline.OutputPath + filesep + "derivatives");
    sn.SessionInfo.Navigation.Refresh;
catch ME
    uialert(app.UIFigure, "Could not open dataset in SurfNIRS: " + ME.message, "Open failed");
end
end