# Striatal Subregions SBR_PIPELINE
 Project Overview

This project focuses on the optimization of a multi-modal pipeline for DaT-SPECT Striatal Binding Ratio (SBR) assessment, leveraging high-resolution MRI-based segmentation of deep gray matter structures. The goal is to enhance the diagnostic accuracy and sensitivity of DaT-SPECT imaging in early Parkinson’s disease by integrating anatomical information from MRI scans and atlas-based masks.

A key component of this pipeline involves the use of a probabilistic connectivity-based striatal atlas—specifically, the striatum-con-label-thr25/50-7sub[^1]—which segments the striatum into seven functional sub-regions. These sub-regions are defined according to cortico-striatal connectivity patterns, with each voxel labeled based on its highest-probability connection to one of seven cortical zones: limbic, executive, rostral-motor, caudal-motor, parietal, occipital, and temporal.

By incorporating these connectivity-driven sub-regions, the project aims to:

-Increase anatomical precision in the localization of dopaminergic decline.
-Improve the sensitivity of SBR measurements to detect subtle, early-stage alterations, especially those initiating in posterior motor regions of the putamen—commonly affected in prodromal Parkinson's disease.
-Support a more functionally relevant interpretation of SBR reductions with symptom domains such as motor control, cognition, and limbic processing.

 Project Objectives:

- Develop a semi-automated pipeline  combining MRI and DaT-SPECT modalities.
- Use FSL masks to segment the striatum into 7 subregions.
- Calculate SBR values based on accurate anatomical segmentation.

The project was conducted at LEMON Lab at Tel Aviv Sourasky Medical Center.


Requirements

- MATLAB R2021a or higher
- Bash Shell (for running `.sh` scripts)
- FSL (FMRIB Software Library) installed
- SPM12 Toolbox (for image preprocessing)

 Folder Structure


SBR_PIPLINE/
├── scripts/
│   ├── COREGISTER.m
│   ├── co.m
│   ├── co_job.m
│   ├── reslic_and_mask.m
│   ├── segment_normalise.m
│   ├── extract_striatum_all_patients.txt
│   ├── register_white_matter_to_DAT.sh
│   ├── calculate_mean_intensity_all.sh
├── data/
│   ├── MRI and DaT-SPECT scans (organized by subject)
├── masks/
│   ├── FSL-derived masks (e.g., striatum_t1_orientation.nii.gz, JHU-SLF masks)
├── results/
│   ├── Mean_Intensity_Results.csv

 Main Scripts and Their Purpose

- COREGISTER.m - Coregisters DaT-SPECT images to MNI standard space.
- co.m + co_job.m - Helper function and batch job for SPM coregistration.
- reslic_and_mask.m - Reslices masks to match DaT-SPECT images.
- segment_normalise.m - Normalizes MRI images to MNI space.
- extract_striatum_all_patients.txt - Extracts 7 striatal subregions from the FSL mask.
- register_white_matter_to_DAT.sh - Registers a white matter mask to DaT-SPECT scans.
- calculate_mean_intensity_all.sh - Calculates mean intensity values for SLF, Occipital, and each striatal subregion.

 Basic Usage

 Coregister DaT-SPECT Scans to MNI

Reference = 'path/to/symFPCITtemplate_MNI_norm.nii';
Source = 'path/to/DAT1/SCAN_A.nii,1';
co(Reference, Source);

Or batch process multiple subjects:

COREGISTER;


 Normalize MRI Scans:

segment_normalise;

 Extract Striatum Subregions:

bash extract_striatum_all_patients.txt


 Register White Matter Mask to DaT-SPECT:
bash register_white_matter_to_DAT.sh


 Calculate Mean Intensity Values:

bash calculate_mean_intensity_all.sh

 Statistical Analysis:
Correlation with Clinical Scores:

correlate_subregions_with_scores;
 Correlation and ICC between Regions



Flowchart of the Pipeline


MRI Scan --> Normalize to MNI (segment_normalise.m)
          --> Extract 7 Striatal Subregions (extract_striatum_all_patients.txt)

DaT-SPECT Scan --> Coregister to MNI Space (COREGISTER.m)
                 --> Reslice and Apply Masks (reslic_and_mask.m)
                 --> Register White Matter Mask (register_white_matter_to_DAT.sh)

Final Step --> Calculate Mean Intensities (calculate_mean_intensity_all.sh)
             --> Compute SBR values ,SBR was normalized to white matter "Superior longitudinal fasciculus (SLF)"
                   SBR =(Mean Mask - Mean SLF)/Mean SLF

Post-Processing --> Statistical Analysis 

Credits
 
- Dr. Amgad Droby (Academic Supervisor): amgadd@tlvmc.gov.il
- Prof. Anat Mirelman (Research Collaboration) :anatmi@tlvmc.gov.il
-Braah krayem (project developer): braah.krayem27@gmail.com

Notes

- This repository is tailored to the LEMON Lab dataset and its folder structure.
- 7 striatal subregions are extracted using FSL masks aligned to each subject's MRI.
- Segmentation was performed based on FSL masks and anatomical references.
- Statistical analyses include Spearman correlations with clinical scores and ICC evaluations.
Reference:
[^1]: [Striatal Connectivity Atlas (Harvard)](https://ftp.nmr.mgh.harvard.edu/pub/dist/freesurfer/tutorial_packages/centos6/fsl_507/doc/wiki/Atlases(2f)striatumconn.html)


