function OpenPath(pathToOpen)
% Opens a file or folder using the OS default handler.
arguments
    pathToOpen (1,1) string
end

if strlength(pathToOpen) == 0 || ~(isfile(pathToOpen) || isfolder(pathToOpen))
    error("GUI:PathNotFound", "Path does not exist: %s", pathToOpen);
end

if ispc
    winopen(char(pathToOpen));
elseif ismac
    system("open " + """" + pathToOpen + """");
else
    system("xdg-open " + """" + pathToOpen + """ &");
end
end