function co(Reference, Source)
    %% Loading the relevant folders and tools 
    % Load SPM
    spm

    %%
    %% Coregister
    nrun = 1; % enter the number of runs here
    jobfile = {'C:\Users\ACER\OneDrive\Desktop\braah_project\scripts\co_job.m'};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(0, nrun);
    for crun = 1:nrun
        inputs{1, crun} = {Reference}; % Coregister: Estimate: Reference Image - cfg_files
        inputs{2, crun} = {Source};
    end
    spm('defaults', 'FMRI');
    spm_jobman('run', jobs, inputs{:});
   
end
