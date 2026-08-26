% RunApp.m
% Convenience launcher for the fNIRS Preprocessing GUI.
% Requires MATLAB 2026a. Run this script from a folder that has +GUI on
% its path (i.e. run from this project's root folder, or addpath() it
% first).
%
% The app's own startupFcn (App.mlapp) calls GUI.startup(app) once the
% figure/menus/layout exist, which prompts for a new/loaded pipeline and
% builds the step rows - see +GUI/startup.m.

app = GUI.App(); %#ok<NASGU>
