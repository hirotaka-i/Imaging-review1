  % %% Adding necessary paths
% addpath('/Users/linoysahar/Desktop/degree/Final_Project/Daniel_Project/Scripts');
% addpath('/Users/linoysahar/Desktop/degree/Final_Project/Daniel_Project/spm12');
% addpath('/Users/linoysahar/Desktop/degree/Final_Project/Daniel_Project/DAT_SCANS_Coregister_Normalise/test');
% occipital_src = '/Users/linoysahar/Desktop/degree/Final_Project/Daniel_Project/Masks/fOccipital.nii';
% 
% %% Define the main data path
% data_path = '/Users/linoysahar/Desktop/degree/Final_Project/Daniel_Project/DAT_SCANS_Coregister_Normalise/test';
% 
% %% Get a list of subject folders in the main data path
% subject_folders = dir(data_path);
% subject_folders = subject_folders([subject_folders.isdir]);  % Keep only folders
% subject_folders = subject_folders(~ismember({subject_folders.name}, {'.', '..'}));  % Exclude '.' and '..'
% 
% %% Reslice and mask for Occipital Lobe
% for i = 1:numel(subject_folders)
%     subject_folder = subject_folders(i).name;
%     subject_path = fullfile(data_path, subject_folder);
% 
%     % DAT1
%     dat1_folder = fullfile(subject_path, 'DAT1');
%     process_occipital(dat1_folder);
% 
%     % DAT2
%     dat2_folder = fullfile(subject_path, 'DAT2');
%     process_occipital(dat2_folder);
% end
% 
% function process_occipital(dat_folder)
%     % Only copy if fOccipital.nii doesn't already exist
%     if ~exist(fullfile(dat_folder, 'fOccipital.nii'), 'file')
%         copyfile(occipital_src, dat_folder);
%     end
% 
%     Reference = fullfile(dat_folder, 'SCAN_A.nii,1');
% 
%     OCC = fullfile(dat_folder, 'fOccipital.nii,1');
%     reslice_try(Reference, OCC);
% 
%     OCC_slice = fullfile(dat_folder, 'rfOccipital.nii,1');
%     cd(dat_folder);
%     mask(OCC_slice);
% end

%% Adding necessary paths
addpath('C:\Users\ACER\OneDrive\Desktop\braah_project\scripts');
addpath('C:\Users\ACER\OneDrive\Desktop\braah_project\spm12');
addpath('C:\Users\ACER\OneDrive\Desktop\braah_project\DAT_SCAN-original');

occipital_src = 'C:\Users\ACER\OneDrive\Desktop\braah_project\masks\fOccipital.nii';

%% Define the main data path
data_path = 'C:\Users\ACER\OneDrive\Desktop\braah_project\DAT_SCAN-original';

%% Get a list of subject folders in the main data path
subject_folders = dir(data_path);
subject_folders = subject_folders([subject_folders.isdir]);  % Keep only folders
subject_folders = subject_folders(~ismember({subject_folders.name}, {'.', '..'}));  % Exclude '.' and '..'

%% Reslice and mask for Occipital Lobe
for i = 1:numel(subject_folders)
    subject_folder = subject_folders(i).name;
    subject_path = fullfile(data_path, subject_folder);

    % Process DAT1 if the folder exists
    dat1_folder = fullfile(subject_path, 'DAT1');
    if exist(dat1_folder, 'dir')
        process_occipital(dat1_folder);
    else
        disp(['DAT1 folder does not exist for subject ' subject_folder]);
    end

    % Process DAT2 if the folder exists
    dat2_folder = fullfile(subject_path, 'DAT2');
    if exist(dat2_folder, 'dir')
        process_occipital(dat2_folder);
    else
        disp(['DAT2 folder does not exist for subject ' subject_folder]);
    end
end

function process_occipital(dat_folder)
    % Only copy if fOccipital.nii doesn't already exist
    occipital_src ='C:\Users\ACER\OneDrive\Desktop\braah_project\masks\fOccipital.nii';
    if ~exist(fullfile(dat_folder, 'fOccipital.nii'), 'file')
        copyfile(occipital_src, fullfile(dat_folder, 'fOccipital.nii'));
    end

    Reference = fullfile(dat_folder, 'SCAN_A.nii');
    if ~exist(Reference, 'file')
    disp(['Missing SCAN_A.nii in: ' dat_folder]);
    return;
    end

    OCC = fullfile(dat_folder, 'fOccipital.nii');
    reslice_try(Reference, OCC);

    OCC_slice = fullfile(dat_folder, 'rfOccipital.nii');
    threshold_occipital(OCC_slice, OCC_slice);
end

function threshold_occipital(input_file, output_file)
    % Read the image
    occipital_img = spm_read_vols(spm_vol(input_file));
    
    % Apply a threshold to create a binary mask
    threshold_value = 0.5;  % Adjust this threshold value as needed
    binary_occipital_img = occipital_img > threshold_value;
    
    % Create a new V structure to specify the output file format
    V = spm_vol(input_file);
    V.fname = output_file;
    
    % Write the binary image to the new file
    spm_write_vol(V, binary_occipital_img);
end



