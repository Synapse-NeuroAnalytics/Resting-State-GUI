function pipeline = ApplyRootSwap(pipeline, oldRoot, newRoot)
% Applies a detected path-root swap (see FindCommonRootSwap) to a
% pipeline's RawDataPath/SpreadsheetPath/OutputPath, but only for fields
% that are currently broken AND where the swap actually resolves to a
% real file/folder. Fields that already exist are left untouched, and
% fields that still don't resolve after the swap are left as-is too, so
% the normal missing-path prompt can still ask about them.
arguments
    pipeline
    oldRoot (1,1) string
    newRoot (1,1) string
end

fieldsToTry = ["RawDataPath", "SpreadsheetPath", "OutputPath"];
for k = 1:numel(fieldsToTry)
    fieldName = fieldsToTry(k);
    val = pipeline.(fieldName);

    if strlength(val) == 0 || isfile(val) || isfolder(val)
        continue  % empty, or already fine - leave it alone
    end
    if ~startsWith(val, oldRoot)
        continue  % this field doesn't share the detected root, skip it
    end

    candidate = newRoot + extractAfter(val, strlength(oldRoot));
    if isfile(candidate) || isfolder(candidate)
        pipeline.(fieldName) = candidate;
    end
end
end
