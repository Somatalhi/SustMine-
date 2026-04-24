%---------------------------------------------------------
% Title: SustMine – A Framework for Integrating
% Sustainable Development into Strategic Mine Planning
%
% Author: Hussam N. Altalhi
% Advisor: Dr. Kwame Awuah-Offei
%---------------------------------------------------------

%% Description:
% This MATLAB implementation demonstrates the SustMine Framework,
% a Pareto front-based approach to integrate multiple sustainable
% development (SD) indicators into strategic mine planning without
% assigning weights by utilizing the order of the Pareto fronts as indices.

% The framework discretizes continuous indicators using Jenks Natural
% Breaks with a GVF (Goodness of Variance Fit) threshold to avoid
% sensitivity to measurement accuracy, then ranks mine plan alternatives
% through a hierarchical Pareto dominance structure.

% The process consists of the following stages:
%   1. Data normalization (scaled to [0, 10])
%   2. Jenks Natural Breaks classification (with GVF >= 0.80)
%   3. Within-dimension Pareto front ranking:
%      - Economic Dimension
%      - Environmental Dimension
%      - Social Dimension
%   4. Aggregation of dimension-level ranks
%   5. Final composite Pareto front ranking
%   6. Effectiveness metrics:
%      - Number of Pareto Fronts (NPF)
%      - Shannon Entropy of the composite front distribution (log base 2)
%   7. Visualization of the 3D sustainability space
%   8. A heat map of SD dimension indices and overall sustainability
%      composite index

%% Sensitivity Analysis:
% A separate sensitivity analysis script (sensitivity_analysis.m) is
% included to assess the robustness of the SustMine framework results
% across three dimensions:
%
%   1. Normalization Method Sensitivity:
%      Compares the baseline min-max normalization against:
%        - Z-score standardization
%        - Rank-based normalization
%      Reports composite index agreement and Front 1 stability.
%
%   2. GVF Threshold Sensitivity:
%      Tests five GVF thresholds: 0.70, 0.75, 0.80, 0.85, and 0.90.
%      Reports Front 1 composition and Shannon entropy for each threshold.
%
%   3. Leave-One-Out Indicator Sensitivity:
%      Removes one indicator at a time from the full set of retained SDIs
%      and recomputes the composite index for all alternatives.
%      Reports Front 1 stability and composite index agreement with
%      the baseline for each excluded indicator.

%% Files Included:
%   - main.m                  : Main script to run the full framework
%   - jenks_gvf.m             : GVF-based Jenks classification function
%   - jenks_breaks.m          : Core function to compute Jenks breaks
%   - pareto_rank.m           : Function to compute Pareto front ranks
%   - sensitivity_analysis.m  : Script to run the full sensitivity analysis

%% Input:
%   - SustMine_SDI_values.xlsx : Matrix of SDI values for all alternatives
%     (rows = alternatives, columns = indicators)
%     Place this file in the same folder as the scripts before running.

%% Output (main.m):
%   - Table showing the rank of each alternative by SD dimension
%   - Composite Pareto front rank
%   - Shannon entropy of the composite front distribution
%   - 3D scatter plot of Economic, Environmental, and Social ranks
%     (color-coded by composite rank)
%   - Heat map of SD dimension indices and sustainability composite index

%% Output (sensitivity_analysis.m):
%   - Composite index comparison across normalization methods
%   - Front 1 composition and Shannon entropy across GVF thresholds
%   - Front 1 stability and composite index agreement for each
%     leave-one-out indicator exclusion

%% Column Order of SDI Input Data:
%   [NPV, Tax, Royalties, GHG, Energy, NOx, PM10, Land Occupation,
%    Waste, ARD, Reclamation, Employees, Job Security,
%    Pit Utilization, Operational Safety]
%
% Note: Maximization indicators (NPV, Employees, Job Security,
%       Pit Utilization) are internally inverted for Pareto logic
%       (i.e., converted to minimization problems).

%% Shannon Entropy Note:
%   Shannon entropy is computed using log base 2 (result in bits).
%   The theoretical maximum for a perfectly uniform distribution of
%   20 alternatives across 5 Pareto fronts is log2(5) = 2.322.
%   The observed value of 2.23 represents 96% of this maximum,
%   confirming strong and well-balanced discrimination among alternatives.

%% How to Run:
%   1. Place all .m files and SustMine_SDI_values.xlsx in the same folder.
%   2. Open MATLAB and navigate to that folder.
%   3. Run main.m to reproduce the main framework results.
%   4. Run sensitivity_analysis.m to reproduce the sensitivity analysis.
%   Tested on MATLAB R2024a.

%% Citation:
%   If you use SustMine in your research, please cite:
%   Altalhi, H., Awuah-Offei, K., Nicolosi, G., Al Moinee, A., and
%   Al Habib, N. (2025). "SustMine: A Framework for Integrating
%   Sustainable Development Dimensions into Strategic Mine Planning."
%   Mining, Metallurgy & Exploration.

%% Contact:
%   For questions, please contact:
%   Hussam N. Altalhi | hna2xf@mst.edu
