%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SustMine Sensitivity Analysis
% Tests three methodological choices:
% 1. Normalization method sensitivity
% 2. GVF threshold sensitivity
% 3. Leave-one-out indicator sensitivity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;

%% ============================================================
% LOAD AND PREPARE DATA
% ============================================================
DM_raw = readmatrix('SustMine_SDI_values.xlsx');

% Column indices
col_NPV=1; col_Tax=2; col_Royalties=3; col_GHG=4; col_Energy=5;
col_NOx=6; col_PM10=7; col_LandOcc=8; col_Waste=9; col_ARD=10;
col_Reclamation=11; col_Employees=12; col_JobSec=13;
col_PitUtil=14; col_Safety=15;

% Columns to maximize (flip sign)
max_cols = [col_NPV, col_Employees, col_JobSec, col_PitUtil];

% Dimension groupings
eco_cols  = [col_NPV, col_Tax, col_Royalties];
env_cols  = [col_GHG, col_Energy, col_NOx, col_PM10, col_LandOcc, ...
             col_Waste, col_ARD, col_Reclamation];
soc_cols  = [col_Employees, col_JobSec, col_PitUtil, col_Safety];

indicator_names = {'NPV','Tax','Royalties','GHG','Energy','NOx',...
                   'PM10','LandOcc','Waste','ARD','Reclamation',...
                   'Employees','JobSec','PitUtil','Safety'};

% Helper function: flip signs for maximization
function DM = flip_signs(DM_in, max_cols)
    DM = DM_in;
    DM(:, max_cols) = -DM(:, max_cols);
end

% Helper function: compute composite index from normalized+classified data
function [eco_idx, env_idx, soc_idx, comp_idx] = compute_indices(...
        DM_norm, eco_cols, env_cols, soc_cols, gvf_thresh)
    n = size(DM_norm, 2);
    DM_class = zeros(size(DM_norm));
    for i = 1:n
        [DM_class(:,i), ~] = jenks_gvf(DM_norm(:,i), gvf_thresh, 8);
    end
    eco_idx  = pareto_rank(DM_class(:, eco_cols));
    env_idx  = pareto_rank(DM_class(:, env_cols));
    soc_idx  = pareto_rank(DM_class(:, soc_cols));
    comp_idx = pareto_rank([eco_idx, env_idx, soc_idx]);
end

% Helper: Shannon entropy
function H = shannon(comp_idx)
    uR = unique(comp_idx);
    counts = zeros(length(uR),1);
    for i = 1:length(uR)
        counts(i) = sum(comp_idx == uR(i));
    end
    p = counts / sum(counts);
    H = -sum(p .* log2(p));
end

%% ============================================================
% BASELINE (original method: min-max, GVF=0.80)
% ============================================================
DM_flipped = flip_signs(DM_raw, max_cols);

% Min-max normalization [0-10]
DM_minmax = zeros(size(DM_flipped));
for i = 1:size(DM_flipped,2)
    DM_minmax(:,i) = 10*(DM_flipped(:,i)-min(DM_flipped(:,i))) / ...
                        (max(DM_flipped(:,i))-min(DM_flipped(:,i)));
end

[eco_base, env_base, soc_base, comp_base] = ...
    compute_indices(DM_minmax, eco_cols, env_cols, soc_cols, 0.80);

fprintf('\n========== BASELINE RESULTS (Min-Max, GVF=0.80) ==========\n');
fprintf('Schedule | Eco | Env | Soc | Composite\n');
for i = 1:20
    fprintf('S%-8d | %3d | %3d | %3d | %3d\n', i, ...
        eco_base(i), env_base(i), soc_base(i), comp_base(i));
end
fprintf('Front 1 schedules: ');
disp(find(comp_base==1)');
fprintf('Shannon Entropy: %.4f\n', shannon(comp_base));

%% ============================================================
% SENSITIVITY 1: NORMALIZATION METHOD
% ============================================================
fprintf('\n========== SENSITIVITY 1: NORMALIZATION METHOD ==========\n');

% Method 2: Z-score normalization scaled to [0-10]
DM_zscore = zeros(size(DM_flipped));
for i = 1:size(DM_flipped,2)
    mu = mean(DM_flipped(:,i));
    sg = std(DM_flipped(:,i));
    if sg == 0
        DM_zscore(:,i) = zeros(size(DM_flipped,1),1);
    else
        z = (DM_flipped(:,i) - mu) / sg;
        DM_zscore(:,i) = 10*(z - min(z)) / (max(z) - min(z));
    end
end

% Method 3: Rank-based normalization scaled to [0-10]
DM_rank = zeros(size(DM_flipped));
for i = 1:size(DM_flipped,2)
    [~, idx] = sort(DM_flipped(:,i));
    r = zeros(size(DM_flipped,1),1);
    r(idx) = 1:size(DM_flipped,1);
    DM_rank(:,i) = 10*(r-1)/(size(DM_flipped,1)-1);
end

[~,~,~, comp_zscore] = compute_indices(DM_zscore, eco_cols, env_cols, soc_cols, 0.80);
[~,~,~, comp_rank_n] = compute_indices(DM_rank,   eco_cols, env_cols, soc_cols, 0.80);

fprintf('\nComposite Index Comparison across normalization methods:\n');
fprintf('Schedule | Baseline(MinMax) | Z-score | Rank-based\n');
for i = 1:20
    fprintf('S%-8d | %15d | %7d | %10d\n', i, ...
        comp_base(i), comp_zscore(i), comp_rank_n(i));
end

% Check Front 1 stability
f1_base   = find(comp_base==1)';
f1_zscore = find(comp_zscore==1)';
f1_rank   = find(comp_rank_n==1)';

fprintf('\nFront 1 — Baseline:    Schedules %s\n', num2str(f1_base));
fprintf('Front 1 — Z-score:     Schedules %s\n', num2str(f1_zscore));
fprintf('Front 1 — Rank-based:  Schedules %s\n', num2str(f1_rank));

fprintf('\nShannon Entropy — Baseline:   %.4f\n', shannon(comp_base));
fprintf('Shannon Entropy — Z-score:    %.4f\n', shannon(comp_zscore));
fprintf('Shannon Entropy — Rank-based: %.4f\n', shannon(comp_rank_n));

% Agreement matrix
agree_zs = sum(comp_base == comp_zscore);
agree_rn = sum(comp_base == comp_rank_n);
fprintf('\nSchedules with identical composite index vs baseline:\n');
fprintf('Z-score vs Baseline:    %d/20\n', agree_zs);
fprintf('Rank-based vs Baseline: %d/20\n', agree_rn);

%% ============================================================
% SENSITIVITY 2: GVF THRESHOLD
% ============================================================
fprintf('\n========== SENSITIVITY 2: GVF THRESHOLD ==========\n');

gvf_values = [0.70, 0.75, 0.80, 0.85, 0.90];
gvf_results = zeros(20, length(gvf_values));

for g = 1:length(gvf_values)
    [~,~,~, comp_g] = compute_indices(DM_minmax, eco_cols, env_cols, soc_cols, gvf_values(g));
    gvf_results(:,g) = comp_g;
end

fprintf('\nComposite Index across GVF thresholds:\n');
fprintf('Schedule | GVF=0.70 | GVF=0.75 | GVF=0.80 | GVF=0.85 | GVF=0.90\n');
for i = 1:20
    fprintf('S%-8d | %8d | %8d | %8d | %8d | %8d\n', i, ...
        gvf_results(i,1), gvf_results(i,2), gvf_results(i,3), ...
        gvf_results(i,4), gvf_results(i,5));
end

fprintf('\nFront 1 schedules per GVF threshold:\n');
for g = 1:length(gvf_values)
    f1 = find(gvf_results(:,g)==1)';
    fprintf('GVF=%.2f: Schedules %s\n', gvf_values(g), num2str(f1));
end

fprintf('\nShannon Entropy per GVF threshold:\n');
for g = 1:length(gvf_values)
    fprintf('GVF=%.2f: %.4f\n', gvf_values(g), shannon(gvf_results(:,g)));
end

%% ============================================================
% SENSITIVITY 3: LEAVE-ONE-OUT INDICATOR ANALYSIS
% ============================================================
fprintf('\n========== SENSITIVITY 3: LEAVE-ONE-OUT ANALYSIS ==========\n');

all_cols = 1:15;
loo_results = zeros(20, 15);

for excl = 1:15
    remaining = setdiff(all_cols, excl);

    % Rebuild dimension groupings without excluded indicator
    eco_loo = intersect(eco_cols,  remaining);
    env_loo = intersect(env_cols,  remaining);
    soc_loo = intersect(soc_cols,  remaining);

    % Remap column indices into reduced matrix
    DM_loo = DM_minmax(:, remaining);
    new_eco = arrayfun(@(c) find(remaining==c), eco_loo);
    new_env = arrayfun(@(c) find(remaining==c), env_loo);
    new_soc = arrayfun(@(c) find(remaining==c), soc_loo);

    % Classify
    DM_class_loo = zeros(size(DM_loo));
    for i = 1:size(DM_loo,2)
        [DM_class_loo(:,i), ~] = jenks_gvf(DM_loo(:,i), 0.80, 8);
    end

    % Handle case where a dimension becomes empty
    if isempty(new_eco)
        eco_loo_idx = ones(20,1);
    else
        eco_loo_idx = pareto_rank(DM_class_loo(:, new_eco));
    end
    if isempty(new_env)
        env_loo_idx = ones(20,1);
    else
        env_loo_idx = pareto_rank(DM_class_loo(:, new_env));
    end
    if isempty(new_soc)
        soc_loo_idx = ones(20,1);
    else
        soc_loo_idx = pareto_rank(DM_class_loo(:, new_soc));
    end

    comp_loo = pareto_rank([eco_loo_idx, env_loo_idx, soc_loo_idx]);
    loo_results(:, excl) = comp_loo;
end

fprintf('\nFront 1 stability when each indicator is excluded:\n');
fprintf('%-15s | Front 1 schedules         | Change from baseline?\n', 'Excluded SDI');
fprintf('%s\n', repmat('-',65,1));
for excl = 1:15
    f1_loo  = find(loo_results(:,excl)==1)';
    changed = ~isequal(sort(f1_base), sort(f1_loo));
    fprintf('%-15s | %-25s | %s\n', indicator_names{excl}, ...
        num2str(f1_loo), string(changed));
end

fprintf('\nComposite index agreement with baseline (leave-one-out):\n');
fprintf('%-15s | Identical rankings | Shannon Entropy\n', 'Excluded SDI');
fprintf('%s\n', repmat('-',55,1));
for excl = 1:15
    agree = sum(loo_results(:,excl) == comp_base);
    H_loo = shannon(loo_results(:,excl));
    fprintf('%-15s | %17d/20 | %.4f\n', indicator_names{excl}, agree, H_loo);
end

fprintf('\n========== SENSITIVITY ANALYSIS COMPLETE ==========\n');
