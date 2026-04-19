%% pareto_rank
% ---------------------------------------------------------
% Function Name: pareto_rank
% Purpose:
%   Assigns Pareto front ranks to a set of multi-objective data points.
%   Used for non-dominated sorting.
%
% Inputs:
%   data - An (n × m) matrix where:
%          n = number of alternatives or solutions
%          m = number of objectives (indicators)
%          Each row represents one solution across all objectives.
%
% Outputs:
%   ranks - An (n × 1) vector of Pareto front ranks:
%           Rank 1: Non-dominated solutions (best)
%           Rank 2: Next front after removing rank 1, etc.
%
% Description:
%   This function computes successive Pareto fronts using the principle
%   of dominance:
%
%     A dominates B if A is no worse than B in all objectives,
%     and better in at least one.
%
%   The algorithm iteratively identifies the current set of non-dominated
%   solutions, assigns them the current front rank, and removes them
%   from further consideration. This continues until all solutions are ranked.
%
% Example Usage:
%   data = [1 4; 2 3; 3 2; 4 1];
%   ranks = pareto_rank(data);
%
%   % Output:
%   % ranks = [1; 1; 1; 1]  (all non-dominated)
%
% Notes:
%   - The function assumes minimization for all objectives.
%   - Flip signs of maximization indicators before passing data.
% ---------------------------------------------------------
function ranks = pareto_rank(data)
    n = size(data, 1);
    ranks = zeros(n, 1);
    currentRank = 1;
    remaining = 1:n;
    while ~isempty(remaining)
        isPareto = true(length(remaining), 1);
        for i = 1:length(remaining)
            for j = 1:length(remaining)
                if all(data(remaining(j), :) <= data(remaining(i), :)) && ...
                   any(data(remaining(j), :) < data(remaining(i), :))
                    isPareto(i) = false;
                    break;
                end
            end
        end
        ranks(remaining(isPareto)) = currentRank;
        remaining = remaining(~isPareto);
        currentRank = currentRank + 1;
    end
end
