
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
%   2. Jenks Natural Breaks classification (with GVF ≥ 0.80)
%   3. Within-dimension Pareto front ranking:
%      - Economic Dimension
%      - Environmental Dimension
%      - Social Dimension
%   4. Aggregation of dimension-level ranks
%   5. Final composite Pareto front ranking
%   6. Visualization of the 3D sustainability space
%   7. A heat map of SD dimensions indices and sustainability overall composite index 

%% Files Included:
%   - main.m              : Main script to run the full framework
%   - jenks_gvf.m         : GVF-based Jenks classification function
%   - jenks_breaks.m      : Core function to compute Jenks breaks
%   - pareto_rank.m       : Function to compute Pareto front ranks

%% Output:
%   - Table showing the rank of each alternative by SD dimension
%   - Composite Pareto front rank
%   - 3D scatter plot of Economic, Environmental, and Social ranks
%     (color-coded by composite rank)

%% Notes:
% - Indicators expected in column order:
%   [NPV, Royalties, Energy, Waste, Employment, Pit Utilization]
% - Maximization indicators (NPV, Employment, Utilization) are internally
%   inverted for Pareto logic (i.e., converted to minimization).
% - A heat map of SD dimensions indices and sustainability overall composite index 

%% Contact:
% For questions, please contact:
%   Hussam N. Altalhi | hna2xf@mst.edu
