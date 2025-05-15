function x=mask(input)
    % List of open inputs
    nrun = 1; % enter the number of runs here
    jobfile = {'C:\Users\danie\Desktop\Final_Project\mask_job.m'};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(1, nrun);
    for crun = 1:nrun
            inputs{1, crun} = {input}; % Coregister: Reslice: Image Defining Space - cfg_files
    end
spm('defaults', 'FMRI');
inputs{:}
spm_jobman('run', jobs, inputs{:});
end
