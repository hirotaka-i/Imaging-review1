 DAT‑SPECT Processing & SBR Pipeline

This repository contains MATLAB scripts for preprocessing  DaT-SPECT scans and computing striatal binding ratios (SBR). The pipeline includes co-registration to an MNI DaT template (SPM12), reslicing ROI masks to each subject’s DaT-SPECT grid, and SBR computation using the superior longitudinal fasciculus (SLF; white-matter) as the reference region, with the occipital mean also reported for comparison with prior analyses.

Matlab
% In MATLAB (paths are already set in the scripts; update if needed):

flip;                       % 1) create *_flippedZ.nii in each subject folder
coregister;               % 2) write r*_flippedZ.nii in the template grid
reslice_masks;                         % 3) reslice masks → <subject>/resliced_masks/
extract_means_SBR_all_patients;        % 4) export PPMI_SBR_SLF.xlsx with live SBR formulas

 Expected Folder Layout
├─ spm12\
├─ masks_PPMI\
│   ├─ symFPCITtemplate_MNI_norm.nii        # MNI DaT template (coreg reference)
│   ├─ JHU-SLF-binary.nii                    # SLF reference mask
│   ├─ fOccipital_bin.nii                    # Occipital mask (reported only)
│   ├─ aCAU_lh_bin.nii  aCAU_rh_bin.nii
│   ├─ aPUT_lh_bin.nii  aPUT_rh_bin.nii
│   ├─ pCAU_lh_bin.nii  pCAU_rh_bin.nii
│   ├─ pPUT_lh_bin.nii  pPUT_rh_bin.nii
│   ├─ SN_L_binary.nii  SN_R_binary.nii
│   
│
└─ coregistered_DAT\
    ├─ 101143\   *.nii  (raw SPECT)  r*_flippedZ.nii  resliced_masks\ (filled later)
    ├─ 10xxxx\   ...
    └─ ...

 Scripts

1) `flip.m`
* Scans each subject folder under `coregistered_DAT`, flips all `.nii` along Z, and saves as `*_flippedZ.nii`.
* Skips files already containing `flippedZ` in the name.

 2) `coregister`
* Coregister` to the DaT template: `masks/symFPCITtemplate_MNI_norm.nii`.
* Writes resliced images `r*_flippedZ.nii` in the template grid.
* Includes a center‑of‑mass origin reset to stabilize SPM’s optimization.

 3) `reslice_masks()` (function)
* For each subject, selects a target SPECT:
  * Prefer: `r*flippedZ.nii`
  * Else:   `r*BRAIN_SPECT*.nii`
* Reslices binary masks (nearest‑neighbor) to the target SPECT grid via SPM Coreg: Write.

 4) `extract_means_SBR_all_patients()` (function)
* Reads the SPECT image (same selection logic as above) and each resliced mask.
* Computes mean counts* inside each ROI.
* Uses  SLF mean as the  SBR reference; also reports Occipital mean.
* Exports `SBR_SLF.xlsx` (sheet: `SBR`) with live Excel formulas for each SBR column:

SBR_ROI = (Mean_ROI − Mean_SLF) / Mean_SLF


* Columns include:
  * `SubjectID`, `Mean_WM_SLF_ref`, `Mean_Occ_ref`
  * `Mean_aCAU_lh_bin`, `Mean_aCAU_rh_bin`, …, `Mean_SN_R_binary`
  * `SBR_aCAU_lh_bin`, `SBR_aCAU_rh_bin`, …, `SBR_SN_R_binary`


 Software & Versions

*MATLAB  (tested with R2022b+)
*SPM12 on MATLAB path
****The pipeline performs: Z‑flip, which might be needed to pre-process the ppmi scans.
Credits
 -Braah krayem (project developer): braah.krayem27@gmail.com
- Dr. Amgad Droby (Academic Supervisor): amgadd@tlvmc.gov.il
- Prof. Anat Mirelman (Research Collaboration) :anatmi@tlvmc.gov.il
## Atlases Used
- [ATAG Atlas (Anatomical Atlas of the Striatum)](https://www.nitrc.org/projects/atag/)  
- [Tian 2020 Subcortical Atlas (v1.4 Download)](https://www.nitrc.org/frs/download.php/13364/Tian2020MSA_v1.4.zip)
