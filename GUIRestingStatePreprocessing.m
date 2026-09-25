% RunApp.m
% Convenience launcher for the fNIRS Preprocessing GUI.
% Requires MATLAB 2026a. Run this script from a folder that has +GUI on
% its path (i.e. run from this project's root folder, or addpath() it
% first).
%
% The app's own startupFcn (App.mlapp) calls GUI.startup(app) once the
% figure/menus/layout exist, which prompts for a new/loaded pipeline and
% builds the step rows - see +GUI/startup.m.

%% Add the top-level folder to the path for future sessions

% Get folder (might not be pwd)
[fol,~,~] = fileparts(which(mfilename + ".m"));

% Need to add to path?
if ~contains(path, fol)
    % Display
    fprintf("Adding GUI to path for future sessions: %s\n", fol);

    % Add to path
    path(path, fol);

    % Try to save this folder to the path permanently
    try
        savepath
    catch
        warning("MATLAB Path could not be saved. Directories have been added to the path for this session only.\nThe most common solution is to run MATLAB as admin and try agian.")
    end
end

% Cleanup
clear fol


%% Warn if there are updates (but do not automatically apply)
GUI.CheckUpdates;


%% Start App
app = GUI.App(); %#ok<NASGU>
