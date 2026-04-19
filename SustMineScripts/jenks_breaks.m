% jenks_breaks.m : Computes Jenks natural breakpoints for data classification
% --------------------------------------------------------------------------
% The name of the function is 'jenks_breaks'
% This function has 2 inputs and 1 output.
%
% Inputs:
% data       : A column vector of numerical values to classify (e.g., indicator scores)
% k          : The desired number of classes (positive integer >= 2)
%
% Output:
% breaks     : A (k+1)-element column vector containing the class boundaries,
%              sorted in ascending order. The first element is the minimum
%              value and the last is the maximum value of the input data.
%
% Description:
% This function implements the Jenks natural breaks optimization algorithm,
% which minimizes the total within-class variance and maximizes the variance
% between classes. The resulting breakpoints divide the input data into
% k classes such that values within each class are as similar as possible.
%
% The algorithm uses dynamic programming to compute the optimal class
% boundaries and returns the break values that define the class intervals.
%
% Example usage:
%    breaks = jenks_breaks(data, 4);
%    % returns 5-element vector [min, break1, break2, break3, max]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% *************************************************************************
function breaks = jenks_breaks(data, k)
    % Sort data and ensure column vector
    data = sort(data(:));
    n = length(data);

    % If k is too large for the dataset, reduce it
    if k >= n
        warning('Too many classes (%d) for data length (%d). Reducing k.', k, n);
        k = max(2, n - 1);  % Must have at least 2 classes
    end

    % Initialize matrices
    mat1 = zeros(n+1, k+1);
    mat2 = inf(n+1, k+1);
    mat1(1, :) = 1;
    mat2(1, :) = 0;

    % Dynamic programming to fill matrices
    for l = 2:n+1
        s1 = 0; s2 = 0; w = 0;
        for m = 1:l
            i3 = l - m + 1;
            if i3 < 1 || i3 > n  % Protect against invalid index
                continue;
            end
            val = data(i3);
            s1 = s1 + val;
            s2 = s2 + val^2;
            w = w + 1;
            v = s2 - (s1^2)/w;
            if i3 ~= 1
                for j = 2:k+1
                    if mat2(l, j) >= (v + mat2(i3 - 1, j - 1))
                        mat1(l, j) = i3;
                        mat2(l, j) = v + mat2(i3 - 1, j - 1);
                    end
                end
            end
        end
        mat2(l, 1) = s2 - (s1^2)/w;
    end

    % Backtrack to find break points
    breaks = zeros(k+1, 1);
    breaks(k+1) = data(end);
    c = n + 1;
    for j = k+1:-1:2
        id = mat1(c, j) - 1;
        if id < 1  % Prevent indexing errors
            id = 1;
        end
        breaks(j-1) = data(id);
        c = id;
    end
end
