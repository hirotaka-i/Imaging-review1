
function reslice_masks()
%% Reslice binary masks to each patient's coregistered SPECT (all patients)
% - Searches for SPECT per patient (prefers r*flippedZ.nii, else any r*BRAIN_SPECT*.nii)
% - Reslices masks from masks_PPMI to SPECT grid (SPM Coreg:Write, NN interp)
% - Moves r*.nii outputs into each patient's "resliced_masks" folder
%
% Requires SPM12 on path.

addpath('C:\Users\ACER\OneDrive\Desktop\braah_project\spm12');

root_pat   = 'C:\Users\ACER\OneDrive\Desktop\braah_project\PPMI_CO';
masks_dir  = 'C:\Users\ACER\OneDrive\Desktop\braah_project\masks_PPMI';

% ---- Binary masks (use your *_bin files and SN/SLF) ----
mask_names = { ...
  'JHU-SLF-binary.nii', ...
  'fOccipital_bin.nii', ...
  'aCAU_lh_bin.nii','aCAU_rh_bin.nii','aPUT_lh_bin.nii','aPUT_rh_bin.nii', ...
  'pCAU_lh_bin.nii','pCAU_rh_bin.nii','pPUT_lh_bin.nii','pPUT_rh_bin.nii', ...
  'SN_L_binary.nii','SN_R_binary.nii'};

% --- helper: resolve .nii or .nii.gz (unzip if needed) ---
resolveMask = @(basePath) resolve_mask_local(basePath);

% --- SPM init ---
spm('defaults','FMRI'); spm_jobman('initcfg');

% --- list patients ---
D = dir(root_pat);
D = D([D.isdir] & ~ismember({D.name},{'.','..'}));

total_pat = numel(D); done_pat = 0; skipped_pat = 0;

for s = 1:total_pat
    subj_dir = fullfile(root_pat, D(s).name);

    % --- find SPECT for this subject (prefer r*flippedZ.nii, else r*BRAIN_SPECT*.nii) ---
    F1 = dir(fullfile(subj_dir, 'r*flippedZ.nii'));
    F2 = dir(fullfile(subj_dir, 'r*BRAIN_SPECT*.nii'));
    F = [F1; F2];

    if isempty(F)
        fprintf('[%s] No coregistered SPECT found (expected r*flippedZ.nii or r*BRAIN_SPECT*.nii). Skipping.\n', D(s).name);
        skipped_pat = skipped_pat + 1;
        continue;
    end

    % If multiple, pick the most recent
    [~, idx] = max([F.datenum]);
    spect_img = fullfile(F(idx).folder, F(idx).name);

    % ---- build SPM source list (Nx1 column cell with ,1) ----
    src_list = cell(numel(mask_names),1);
    try
        for i = 1:numel(mask_names)
            p = resolveMask(fullfile(masks_dir, mask_names{i}));
            src_list{i,1} = [p ',1'];
        end
    catch ME
        warning('[%s] Mask resolving failed: %s', D(s).name, ME.message);
        skipped_pat = skipped_pat + 1;
        continue;
    end

    % ---- Coregister: WRITE (reslice masks to spect_img grid) ----
    matlabbatch = [];
    matlabbatch{1}.spm.spatial.coreg.write.ref    = { [spect_img ',1'] };
    matlabbatch{1}.spm.spatial.coreg.write.source = src_list;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0; % nearest-neighbor for binary
    matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.write.roptions.mask   = 0;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

    try
        spm_jobman('run', matlabbatch);
    catch ME
        warning('[%s] Reslice failed: %s', D(s).name, ME.message);
        skipped_pat = skipped_pat + 1;
        continue;
    end

    % ---- Move resliced masks to subject/resliced_masks ----
    dest_dir = fullfile(subj_dir, 'resliced_masks');
    if ~exist(dest_dir,'dir'), mkdir(dest_dir); end

    moved = 0;
    for i = 1:numel(mask_names)
        src_r = fullfile(masks_dir, ['r' mask_names{i}]);   % SPM writes here
        if isfile(src_r)
            [~,nm,~] = fileparts(mask_names{i});            % e.g., aPUT_lh_bin
            dst = fullfile(dest_dir, sprintf('r_%s.nii', nm));
            try
                movefile(src_r, dst, 'f');
                moved = moved + 1;
            catch ME
                warning('[%s] Could not move %s: %s', D(s).name, src_r, ME.message);
            end
        else
            warning('[%s] Expected resliced not found: %s', D(s).name, src_r);
        end
    end

    fprintf('[%s] OK → %d masks moved to %s\n', D(s).name, moved, dest_dir);
    done_pat = done_pat + 1;
end

fprintf('\nSummary: processed=%d | skipped=%d | total=%d\n', done_pat, skipped_pat, total_pat);
end

% ===== helper (local subfunction) =====
function p = resolve_mask_local(p_nifti)
    % If .nii exists, return it; else try .nii.gz and unzip once
    if isfile(p_nifti)
        p = p_nifti; return;
    end
    gz = [p_nifti '.gz'];
    if isfile(gz)
        try
            gunzip(gz);
        catch ME
            error('gunzip failed for %s: %s', gz, ME.message);
        end
        if ~isfile(p_nifti)
            error('After gunzip, missing: %s', p_nifti);
        end
        p = p_nifti; return;
    end
    error('Mask not found: %s (nor %s)', p_nifti, gz);
end
