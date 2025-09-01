%% Loading the relevant folders and tools
addpath('C:\Users\ACER\OneDrive\Desktop\braah_project\spm12');
addpath('C:\Users\ACER\OneDrive\Desktop\braah_project\DAT_SCAN-original');
spm;

data_path = 'C:\Users\ACER\OneDrive\Desktop\braah_project\DAT_SCAN-original';
Reference = 'C:\Users\ACER\OneDrive\Desktop\braah_project\masks\symFPCITtemplate_MNI_norm.nii';

%% Get all folders in the data path
folders = dir(data_path);
folders = folders([folders.isdir]);  % Remove non-folders
folders = folders(~ismember({folders.name}, {'.', '..'}));  % Remove '.' and '..'

%% Loop through each subject folder
for i = 1:numel(folders)
    subject_folder = fullfile(data_path, folders(i).name);
    
    % Check if it's a valid subject folder
    if ~isempty(str2double(folders(i).name))
        % Define the directory paths for DAT1 and DAT2
        dat1_path = fullfile(subject_folder, 'DAT1');
        dat2_path = fullfile(subject_folder, 'DAT2');

        % Process DAT1 files
        process_nifti_files(dat1_path);

        % Process DAT2 files
        process_nifti_files(dat2_path);
    end
end

function process_nifti_files(directory_path)
    % Find the NIfTI files starting with the letter "o"
    file_info = dir(fullfile(directory_path, 'o*.nii'));
    if isempty(file_info)
        disp(['No NIfTI file starting with "o" found in directory: ' directory_path]);
        return;
    end

    % Preprocessing parameters
    % Define the preprocessing parameters...

    % Preprocessing steps
    spm('defaults', 'FMRI');
    spm_jobman('initcfg');

    for j = 1:numel(file_info)
        % Define the input NIfTI file path
        input_nii_path = fullfile(directory_path, file_info(j).name);
        
        % Define the TPM file paths
        tpm_paths = {
            'C:\Users\ACER\OneDrive\Desktop\braah_project\spm12\tpm\TPM.nii,1',
            'C:\Users\ACER\OneDrive\Desktop\braah_project\spm12\tpm\TPM.nii,2',
            'C:\Users\ACER\OneDrive\Desktop\braah_project\spm12\tpm\TPM.nii,3',
            'C:\Users\ACER\OneDrive\Desktop\braah_project\spm12\tpm\TPM.nii,4',
            'C:\Users\ACER\OneDrive\Desktop\braah_project\spm12\tpm\TPM.nii,5',
            'C:\Users\ACER\OneDrive\Desktop\braah_project\spm12\tpm\TPM.nii,6'
            
        };
        
        % Preprocessing parameters
        bias_reg = 0.001;
        bias_fwhm = 60;
        write_channels = [0, 0];
        warp_cleanup = 1;
        warp_reg_params = [0, 0.001, 0.5, 0.05, 0.2];
        warp_vox = NaN;
        warp_bb = [NaN, NaN, NaN; NaN, NaN, NaN];
        normalise_bb = [-78, -112, -70; 78, 76, 85];
        normalise_vox = [2, 2, 2];
        normalise_interp = 4;
        normalise_prefix = 'w';  % Change the prefix to "T1_normelise"
        
        % Preprocessing steps
        spm('defaults', 'FMRI');
        spm_jobman('initcfg');
        
        % Step 1: Segment
        matlabbatch{1}.spm.spatial.preproc.channel.vols = {input_nii_path};
        matlabbatch{1}.spm.spatial.preproc.channel.biasreg = bias_reg;
        matlabbatch{1}.spm.spatial.preproc.channel.biasfwhm = bias_fwhm;
        matlabbatch{1}.spm.spatial.preproc.channel.write = write_channels;
        
        for i = 1:numel(tpm_paths)
            matlabbatch{1}.spm.spatial.preproc.tissue(i).tpm = {tpm_paths{i}};
            matlabbatch{1}.spm.spatial.preproc.tissue(i).ngaus = i;
            matlabbatch{1}.spm.spatial.preproc.tissue(i).native = [1, 0];
            matlabbatch{1}.spm.spatial.preproc.tissue(i).warped = [0, 0];
        end
        
        matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
        matlabbatch{1}.spm.spatial.preproc.warp.cleanup = warp_cleanup;
        matlabbatch{1}.spm.spatial.preproc.warp.reg = warp_reg_params;
        matlabbatch{1}.spm.spatial.preproc.warp.affreg = 'mni';
        matlabbatch{1}.spm.spatial.preproc.warp.fwhm = 0;
        matlabbatch{1}.spm.spatial.preproc.warp.samp = 3;
        matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];  % Write deformation fields
        matlabbatch{1}.spm.spatial.preproc.warp.vox = [warp_vox, warp_vox, warp_vox];
        matlabbatch{1}.spm.spatial.preproc.warp.bb = warp_bb;

        % Step 2: Normalize (Normalise: Write)
        matlabbatch{2}.spm.spatial.normalise.write.subj.def = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{1},...
        '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
        matlabbatch{2}.spm.spatial.normalise.write.subj.resample = {input_nii_path};
        matlabbatch{2}.spm.spatial.normalise.write.woptions.bb = normalise_bb;
        matlabbatch{2}.spm.spatial.normalise.write.woptions.vox = normalise_vox;
        matlabbatch{2}.spm.spatial.normalise.write.woptions.interp = normalise_interp;
        matlabbatch{2}.spm.spatial.normalise.write.woptions.prefix = normalise_prefix;

        % Run the preprocessing steps
        spm_jobman('run', matlabbatch);
        disp(['Preprocessing completed for file: ' file_info(j).name]);
    end
end
