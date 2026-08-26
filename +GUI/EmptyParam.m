function p = EmptyParam(n)
% Preallocates a parameter struct array with the default parameter structure.
arguments
    n (1,1) double = 0
end

template = struct( ...
    "Name",         "", ...
    "Label",        "", ...
    "Type",         "", ...         % "numeric" | "logical" | "dropdown" | "file"
    "Validation",   "none", ...     % Validation rule key
    "Value",        [], ...
    "Default",      [], ...
    "Options",      {{}}, ...
    "Description",  "", ...
    "MarksDirty",       true, ...   % If false, changing this param never flags this step as needing a rerun
    "PropagatesDirty",  true, ...   % If false, changing this param never flags DOWNSTREAM steps (independent of MarksDirty)
    "LastRunValue", []);

if n == 0
    p = template([]);
else
    p = repmat(template, 1, n);
end
end