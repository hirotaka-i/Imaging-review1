%% Loading the relevant folders and tools
addpath('C:\Users\ACER\OneDrive\Desktop\braah_project\spm12')
addpath('C:\Users\ACER\OneDrive\Desktop\braah_project\DAT_SCAN-original')%%%%%
spm

%%
% subjects1=[98,111,7,17,27,506,522,534,539,553];
% subjects2=[98,111,7,17,27,506,522,534,539,553];
%% Get all subject folders dynamically
data_path = 'C:\Users\ACER\OneDrive\Desktop\braah_project\DAT_SCAN-original';
subject_folders = dir(data_path);
subject_folders = subject_folders([subject_folders.isdir]);
subject_ids = [];

for i = 1:length(subject_folders)
    folder_name = subject_folders(i).name;
    if ~strcmp(folder_name, '.') && ~strcmp(folder_name, '..') && ~isnan(str2double(folder_name))
        subject_ids = [subject_ids, str2double(folder_name)];
    end
end

Reference = 'C:\Users\ACER\OneDrive\Desktop\braah_project\masks\symFPCITtemplate_MNI_norm.nii';

% Get a list of all folders (subjects) in the Coregister directory
% subject_folders = dir(fullfile(data_path, '*'));
% subject_folders = subject_folders([subject_folders.isdir]);  % Get only directories
% subject_folders = subject_folders(~ismember({subject_folders.name}, {'.', '..'}));  % Exclude '.' and '..'

% for subject_idx = 1:numel(subject_folders)
%     subject_folder = fullfile(data_path, subject_folders(subject_idx).name);
%     
%     % Check if DAT1 and DAT2 folders exist for this subject
%     dat1_folder = fullfile(subject_folder, 'DAT1');
%     dat2_folder = fullfile(subject_folder, 'DAT2');
%     
%     if exist(dat1_folder, 'dir')
%         % Coregister-DAT1
%         Source_DAT1 = fullfile(dat1_folder, 'SCAN_A.nii,1');
%         co(Reference, Source_DAT1)
%     end
%     
%     if exist(dat2_folder, 'dir')
%         % Coregister-DAT2
%         Source_DAT2 = fullfile(dat2_folder, 'SCAN_A.nii,1');
%         co(Reference, Source_DAT2)
%     end
% end
  % for s=subject_ids
  %     Source_DAT1=strcat(data_path,'\',num2str(s),'\DAT1\SCAN_A.nii,1');
  %      co(Reference, Source_DAT1)
  %     if ismember(s, subjects2)
  %         Source_DAT2=strcat(data_path,'\',num2str(s),'\DAT2\SCAN_A.nii,1');
  %          co(Reference, Source_DAT2)
  %     end
  % end
  for s = subject_ids
    Source_DAT1 = strcat(data_path, '\', num2str(s), '\DAT1\SCAN_A.nii,1');
    if exist(Source_DAT1(1:end-2), 'file')
        co(Reference, Source_DAT1)
    end
    
    Source_DAT2 = strcat(data_path, '\', num2str(s), '\DAT2\SCAN_A.nii,1');
    if exist(Source_DAT2(1:end-2), 'file')
        co(Reference, Source_DAT2)
    end
end


