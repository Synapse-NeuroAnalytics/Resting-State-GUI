function [isValid, errorMsg] = ValidateParam(val, rule, currentStep)
% Validates parameter input against requirements.

% Optional currentStep struct allows cross-parameter validation (e.g., Bandpass filter limits).
if nargin < 3, currentStep = []; end

isValid = true;
errorMsg = "";

if isempty(val) || rule == "none"
    return;
end

switch rule
    case "positive"
        if ~isnumeric(val) || val < 0
            isValid = false;
            errorMsg = sprintf("Value must be zero or a positive number (>= 0). Entered: %s", string(val));
        end

    case "positive_int"
        if ~isnumeric(val) || val <= 0 || mod(val, 1) ~= 0
            isValid = false;
            errorMsg = sprintf("Value must be a positive integer (1, 2, 3, ...). Entered: %s", string(val));
        end

    case "non_negative_int"
        if ~isnumeric(val) || val < 0 || mod(val, 1) ~= 0
            isValid = false;
            errorMsg = sprintf("Value must be 0/empty or a positive integer. Entered: %s", string(val));
        end

    case "range_0_1"
        if ~isnumeric(val) || val < 0 || val > 1
            isValid = false;
            errorMsg = sprintf("Value must be in the range [0.0, 1.0]. Entered: %s", string(val));
        end

    case "range_0_100"
        if ~isnumeric(val) || val < 0 || val > 100
            isValid = false;
            errorMsg = sprintf("Value must be a percentage between 0 and 100. Entered: %s", string(val));
        end

    case "bandpass_high"
        if ~isnumeric(val) || val <= 0
            isValid = false;
            errorMsg = sprintf("Passband upper limit must be positive. Entered: %s", string(val));
        elseif ~isempty(currentStep)
            % Check that HighCutoff > LowCutoff
            lowIdx = find([currentStep.Parameters.Name] == "LowCutoff", 1);
            if ~isempty(lowIdx)
                lowVal = currentStep.Parameters(lowIdx).Value;
                if isnumeric(lowVal) && val <= lowVal
                    isValid = false;
                    errorMsg = sprintf("Passband upper limit (%g Hz) must be greater than lower limit (%g Hz).", val, lowVal);
                end
            end
        end
    case "seeds"
        if ~isempty(val)
            num = str2num(val);
            num(num < 1) = [];
            if any(num ~= round(num))
                isValid = false;
                errorMsg = sprintf("Must be empty or an array of positive integers. Entered: %s", string(val));
            end
        end

end
end