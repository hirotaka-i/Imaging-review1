#!/bin/bash

# Define paths
base_dir="/mnt/c/Users/ACER/OneDrive/Desktop/braah_project/DAT_SCAN-original"
white_matter_mask="/mnt/c/Users/ACER/OneDrive/Desktop/braah_project/masks/JHU-WhiteMatter-labels-1mm.nii.gz"

# Loop through all patient folders
for patient_dir in "$base_dir"/*; do
    if [ -d "$patient_dir" ]; then
        patient_id=$(basename "$patient_dir")
        echo "🔍 Processing Patient: $patient_id"

        # Loop through DAT1 and DAT2
        for dat_folder in "$patient_dir"/DAT1 "$patient_dir"/DAT2; do
            if [ -d "$dat_folder" ]; then
                echo "📁 Processing: $dat_folder"

                # Locate the DAT scan (assumed to be reference)
                dat_scan=$(find "$dat_folder" -type f -name "SCAN_A.nii" | head -n 1)

                if [ -f "$dat_scan" ]; then
                    echo "🧠 Found DAT Scan: $(basename "$dat_scan")"

                    # Define output path for registered white matter mask
                    output_mask="$dat_folder/JHU_WhiteMatter_resampled.nii.gz"

                    # Use FLIRT to register the white matter mask to the DAT scan
                    flirt -in "$white_matter_mask" \
                          -ref "$dat_scan" \
                          -out "$output_mask" \
                          -interp nearestneighbour -dof 6 -cost normcorr

                    echo "✅ Registered White Matter Mask saved as: $(basename "$output_mask")"
                else
                    echo "🚫 DAT scan not found in $dat_folder"
                fi
            fi
        done
    fi
done

echo "✅ White Matter Masks registered for all patients!"
