%% coregister_flippedZ_all.m
% Coregister + Reslice all *_flippedZ.nii to the MNI DaT template (SPM12)

addpath('path_spm12');

data_root = 'output_path';
ref_path  = 'ref_path';

spm('defaults','FMRI'); 
spm_jobman('initcfg');

% Make sure SPM sees a volume index
ref_img = [ref_path ',1'];

subs = dir(data_root);
subs = subs([subs.isdir] & ~ismember({subs.name},{'.','..'}));

for s = 1:numel(subs)
    subj_dir = fullfile(data_root, subs(s).name);

    % find flipped files only
    F = dir(fullfile(subj_dir, '*_flippedZ.nii'));
    if isempty(F)
        fprintf('[%s] no *_flippedZ.nii\n', subs(s).name);
        continue;
    end

    for k = 1:numel(F)
        try
            src_path = fullfile(F(k).folder, F(k).name);

            % --- (recommended) reset origin to center-of-mass to help optimizer ---
            V = spm_vol(src_path); Y = spm_read_vols(V);
            [ix,iy,iz] = ind2sub(V.dim, find(Y>0));
            if isempty(ix), com = (V.dim+1)/2; else, com = [mean(ix) mean(iy) mean(iz)]; end
            com_mm = V.mat*[com 1]';
            M = V.mat; M(1:3,4) = M(1:3,4) - com_mm(1:3);
            spm_get_space(src_path, M);

            % --- Coregister: Estimate & Reslice ---
            matlabbatch = [];
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref    = {ref_img};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[src_path ',1']};
            matlabbatch{1}.spm.spatial.coreg.estwrite.other  = {''};

            % estimation options
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep      = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol      = ...
                [0.02 0.02 0.02  0.001 0.001 0.001  0.01 0.01 0.01  0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm     = [7 7];

            % reslice options (write r*.nii in template grid)
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp   = 4;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap     = [0 0 0];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask     = 0;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix   = 'r';

            spm_jobman('run', matlabbatch);
            fprintf('[%s] OK: %s -> r*.nii\n', subs(s).name, F(k).name);

        catch ME
            warning('[%s] failed on %s: %s', subs(s).name, F(k).name, ME.message);
        end
    end
end

disp('Done. Load template + r*_flippedZ.nii in SPM Check Reg to verify overlap.');
