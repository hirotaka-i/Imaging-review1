function extract_means_SBR_all_patients()
%% Extract mean counts per ROI + compute SBR using SLF as reference, all patients
% - Requires: resliced binary masks in <patient>\resliced_masks\ from prior step
% - Writes Excel with real formulas for SBR columns
% - SPM12 must be on path

addpath('SPM_path');

root_pat  = 'output_path';
out_xlsx  = fullfile(root_pat, 'SBR_SLF.xlsx');

% ---- mask filenames expected INSIDE each subject's "resliced_masks" ----
% (exactly as created by the previous reslicing script)
roi_masks = { ...
    'r_aCAU_lh_bin.nii', 'r_aCAU_rh_bin.nii', ...
    'r_aPUT_lh_bin.nii', 'r_aPUT_rh_bin.nii', ...
    'r_pCAU_lh_bin.nii', 'r_pCAU_rh_bin.nii', ...
    'r_pPUT_lh_bin.nii', 'r_pPUT_rh_bin.nii', ...
    'r_SN_L_binary.nii', 'r_SN_R_binary.nii'};

% reference & (optional) occipital
ref_mask  = 'r_JHU-SLF-binary.nii';     % <-- SBR reference
occ_mask  = 'r_fOccipital_bin.nii';     % optional: mean will be reported

% ---- discover subjects ----
D = dir(root_pat);
D = D([D.isdir] & ~ismember({D.name},{'.','..'}));

% ---- headers for Excel ----
headers = [{'SubjectID','Mean_SLF','Mean_Occ'}, ...
    strcat('Mean_', erase(roi_masks, {'.nii','r_'})), ...
    strcat('SBR_',  erase(roi_masks, {'.nii','r_'}))];

rows = {};  % will build a cell array row-by-row

for s = 1:numel(D)
    subj_dir = fullfile(root_pat, D(s).name);

    % choose SPECT (prefer flippedZ)
    F1 = dir(fullfile(subj_dir,'r*flippedZ.nii'));
    F2 = dir(fullfile(subj_dir,'r*BRAIN_SPECT*.nii'));
    F  = [F1; F2];
    if isempty(F)
        fprintf('[%s] No r* SPECT found. Skipping.\n', D(s).name);
        continue;
    end
    [~,idx] = max([F.datenum]);  % most recent
    spect_img = fullfile(F(idx).folder, F(idx).name);

    % folder with resliced masks
    mdir = fullfile(subj_dir, 'resliced_masks');
    if ~exist(mdir,'dir')
        fprintf('[%s] No resliced_masks folder. Skipping.\n', D(s).name);
        continue;
    end

    % read SPECT volume
    try
        Vs = spm_vol(spect_img);
        Ys = spm_read_vols(Vs);
    catch ME
        warning('[%s] Failed reading SPECT: %s', D(s).name, ME.message);
        continue;
    end

    % --- means ---
    meanSLF = mean_in_mask(Ys, fullfile(mdir, ref_mask));
    meanOcc = mean_in_mask(Ys, fullfile(mdir, occ_mask));  % may be NaN if mask missing

    roi_means = nan(1, numel(roi_masks));
    for i = 1:numel(roi_masks)
        roi_means(i) = mean_in_mask(Ys, fullfile(mdir, roi_masks{i}));
    end

    % build one row (subject id + means; SBR columns added later as formulas)
    row = [{D(s).name}, {meanSLF}, {meanOcc}, num2cell(roi_means)];
    rows(end+1,1:numel(row)) = row; %#ok<AGROW>
end

if isempty(rows)
    error('No subjects processed. Make sure resliced_masks exist and filenames match.');
end

% ---- write means first (so we know cell addresses), then add SBR formulas ----
% We’ll assemble a cell array including formulas starting with '='.
nRows  = size(rows,1);
nMeans = 2 + numel(roi_masks);    % SLF + Occ + ROI means
nCols  = 1 + nMeans + numel(roi_masks);  % Subject + means + SBRs

sheet = 'SBR';
C = cell(nRows+1, nCols);
C(1,1:numel(headers)) = headers;   % header row
C(2:end,1:numel(rows(1,:))) = rows;

% Column letters for Excel formulas
colLetters = arrayfun(@excelCol, 1:nCols, 'uni', 0);

% Indices for columns
col_Subj = 1;
col_SLF  = 2;          % Mean_SLF
col_Occ  = 3;          % Mean_Occ (optional)
col_ROIstart = 4;      % first ROI mean
col_SBRstart = 1 + (1 + nMeans); % after Subject + all means

% For each row, create SBR formulas: SBR_ROI = (ROI - SLF) / SLF
for r = 2:nRows+1
    for k = 1:numel(roi_masks)
        roiCol   = col_ROIstart + (k-1);
        sbrCol   = col_SBRstart + (k-1);
        % Excel formula referencing this row
        roiRef = sprintf('%s%d', colLetters{roiCol}, r);
        slfRef = sprintf('%s%d', colLetters{col_SLF}, r);
        C{r, sbrCol} = sprintf('=(%s-%s)/%s', roiRef, slfRef, slfRef);
    end
end

% Write to Excel (formulas preserved)
writecell(C, out_xlsx, 'Sheet', sheet);

fprintf('\nSaved Excel with means + SBR formulas:\n  %s (sheet: %s)\n', out_xlsx, sheet);
fprintf('SBR formula per row is =(ROI - Mean_SLF) / Mean_SLF\n');

end

% ---------- helpers ----------
function m = mean_in_mask(Ys, mask_path)
% Return mean(Ys(mask==1)); NaN if mask missing or empty
    if ~isfile(mask_path)
        m = NaN; return;
    end
    Vm = spm_vol(mask_path);
    Ym = spm_read_vols(Vm);
    idx = (Ym > 0.5) & isfinite(Ys);
    if ~any(idx(:))
        m = NaN;
    else
        m = mean(Ys(idx));
    end
end

function L = excelCol(n)
% 1->A, 2->B, ... 26->Z, 27->AA ...
    s = '';
    while n > 0
        r = mod(n-1,26);
        s = [char(65+r) s]; %#ok<AGROW>
        n = floor((n-1)/26);
    end
    L = s;
end
