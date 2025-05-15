function x=reslice_try(Reference,Source)
    %% Loading the relevant folders and tools     
    %data_path='B:\Projects\Daniel\DAT_SCANS _Coregister';
    % List of open inputs
    % Coregister: Reslice: Image Defining Space - cfg_files
    % Coregister: Reslice: Images to Reslice - cfg_files
    nrun = 1; % enter the number of runs here
    jobfile = {'C:\Users\ACER\OneDrive\Desktop\braah_project\scripts\reslice_try_job.m'};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(2, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {Reference}; % Coregister: Reslice: Image Defining Space - cfg_files
        inputs{2, crun} = {Source}; % Coregister: Reslice: Images to Reslice - cfg_files
%         inputs{3, crun} = {LP};
%         inputs{4, crun} = {RC};
%         inputs{5, crun} = {RP};
    end
    spm('defaults', 'FMRI');
    spm_jobman('run', jobs, inputs{:});
end
