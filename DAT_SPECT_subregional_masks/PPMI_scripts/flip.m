%% flip_all_ppmi_Z.m
% Flip all .nii images along the Z-axis for all subject folders in PPMI_CO
% Creates new files with suffix "_flippedZ.nii"

addpath('C:\Users\ACER\OneDrive\Desktop\braah_project\spm12');  % SPM path
root_dir = 'C:\Users\ACER\OneDrive\Desktop\braah_project\PPMI_CO';

% Get list of subject folders
d = dir(root_dir);
sub_folders = d([d.isdir] & ~ismember({d.name},{'.','..'}));

for s = 1:numel(sub_folders)
    subj_path = fullfile(root_dir, sub_folders(s).name);

    % Find all NIfTI files in this folder
    nii_files = dir(fullfile(subj_path, '*.nii'));

    for f = 1:numel(nii_files)
        file_path = fullfile(nii_files(f).folder, nii_files(f).name);

        % Skip if it's already flipped
        if contains(nii_files(f).name, 'flippedZ', 'IgnoreCase', true)
            fprintf('Skipping already flipped: %s\n', file_path);
            continue;
        end

        % Load and flip
        V = spm_vol(file_path);
        Y = spm_read_vols(V);
        Y = flip(Y, 3);  % flip along Z

        % Create output name
        [folder, name, ext] = fileparts(file_path);
        V.fname = fullfile(folder, [name '_flippedZ' ext]);

        % Save
        spm_write_vol(V, Y);
        fprintf('Flipped: %s -> %s\n', file_path, V.fname);
    end
end

disp('Done flipping all NIfTI images along Z-axis.');
