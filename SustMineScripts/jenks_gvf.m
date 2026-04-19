function [classLabels, gvf] = jenks_gvf(data, gvfThreshold, maxClasses)
% jenks_gvf.m : Jenks classification with GVF threshold
% --------------------------------------------------------------------------
% This function classifies a numeric vector using Jenks natural breaks.
% It searches for the smallest number of classes (up to maxClasses) such that
% the Goodness of Variance Fit (GVF) meets or exceeds the given threshold.
%
% Inputs:
%   data          : A column vector of numeric values (e.g., indicator values)
%   gvfThreshold  : Minimum desired GVF score (e.g., 0.80)
%   maxClasses    : Maximum number of classes to try (e.g., 8)
%
% Outputs:
%   classLabels   : Vector of discrete class labels (1 to k) assigned to each value
%   gvf           : GVF score achieved at termination
%
% --------------------------------------------------------------------------

% Remove NaNs and ensure column vector
data = data(~isnan(data));
data = data(:);
n = length(data);

% Handle trivial cases
if n < 3
    warning('Not enough data points for Jenks classification. Returning all ones.');
    classLabels = ones(n, 1);
    gvf = 0;
    return;
end

% Compute total squared deviation from mean
sdcm = sum((data - mean(data)).^2);

% Loop through class numbers from 2 to maxClasses
for k = 2:min(maxClasses, length(unique(data)) - 1)
    breaks = jenks_breaks(data, k);
    classLabels = zeros(n, 1);

    % Assign classes based on breaks
    for i = 1:k
        if i == 1
            classLabels(data <= breaks(i+1)) = i;
        else
            classLabels(data > breaks(i) & data <= breaks(i+1)) = i;
        end
    end

    % Compute sum of squared deviations within classes
    sdcmb = 0;
    for i = 1:k
        group = data(classLabels == i);
        sdcmb = sdcmb + sum((group - mean(group)).^2);
    end

    % Compute GVF
    gvf = (sdcm - sdcmb) / sdcm;

    % Check if GVF threshold is satisfied
    if gvf >= gvfThreshold
        return;
    end
end

% If threshold not met, return last attempt
warning('GVF threshold not met. Returning best result with %d classes (GVF = %.2f)', k, gvf);
breaks = jenks_breaks(data, k);
classLabels = zeros(n, 1);
for i = 1:k
    if i == 1
        classLabels(data <= breaks(i+1)) = i;
    else
        classLabels(data > breaks(i) & data <= breaks(i+1)) = i;
    end
end
