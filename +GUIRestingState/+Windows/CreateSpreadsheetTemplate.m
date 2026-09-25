function CreateSpreadsheetTemplate(filepath, rawFolder)
% Writes a blank dataset template spreadsheet to filepath.
% NEEDS TOOLBOX CALL
% Can be replaced with custom spreadsheet template creation script.
arguments
    filepath (1,1) string
    rawFolder (1,1) string
end

% If rawFolder is defined and fNIRS-Preprocessing is available, prepopulate
% the csv
if (rawFolder.strlength > 0) && exist("PipelineSteps.ImportRaw", "class")
    p = Pipeline;
    p.FolderRaw = rawFolder;
    p.CreateAcquisitionCSV(filepath, true);
else
    % Otherwise, just create an empty csv with headers
    columns = ["Include" "Path_To_Raw" "Subject_Number" "Session_Number" "Run_Number" "Cardiac_Min_bpm" "Cardiac_Max_bpm" "Age_years" "Head_Circumference_cm" "iqr_override"];
    T = cell2table(cell(0, numel(columns)), "VariableNames", cellstr(columns));
    
    [folder, ~, ~] = fileparts(filepath);
    if strlength(folder) > 0 && ~isfolder(folder)
        mkdir(folder);
    end
    
    writetable(T, filepath);
end
end