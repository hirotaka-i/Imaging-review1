#!/bin/bash

# Define the output CSV file
output_file="/mnt/c/Users/ACER/OneDrive/Desktop/braah_project/Mean_Intensity_Results.csv"

# Ensure the file is writable
touch "$output_file"
chmod 777 "$output_file"

# Add header to CSV if file is empty
if [ ! -s "$output_file" ]; then
    echo "Patient_ID,Session,Mean_Intensity_SLF,Mean_Intensity_Occipital,Mean_Intensity_Striatum1,Mean_Intensity_Striatum2,Mean_Intensity_Striatum3,Mean_Intensity_Striatum4,Mean_Intensity_Striatum5,Mean_Intensity_Striatum6,Mean_Intensity_Striatum7" > "$output_file"
fi

# Define the original SLF mask path
original_slf_mask="/mnt/c/Users/ACER/OneDrive/Desktop/braah_project/masks/JHU-SLF-tracts-binary.nii.gz"

# Loop through each patient and session
for patient_dir in /mnt/c/Users/ACER/OneDrive/Desktop/braah_project/DAT_SCAN-original/*; do
    if [ -d "$patient_dir" ]; then
        patient_id=$(basename "$patient_dir")

        for dat_folder in "$patient_dir"/DAT1 "$patient_dir"/DAT2; do
            if [ -d "$dat_folder" ]; then
                session=$(basename "$dat_folder")

                # Locate the DAT scan
                dat_scan="$dat_folder/SCAN_A.nii"
                if [ -f "$dat_scan" ]; then
                    echo "🔍 Processing: $dat_scan"

                    # Step 1: Align SLF mask to DAT scan
                    aligned_slf_mask="$dat_folder/JHU-SLF-tracts-binary_aligned.nii.gz"
                    flirt -in "$original_slf_mask" \
                          -ref "$dat_scan" \
                          -out "$aligned_slf_mask" \
                          -applyxfm -usesqform -interp nearestneighbour

                    # Step 2: Ensure the SLF mask is binary
                    fslmaths "$aligned_slf_mask" -bin "$aligned_slf_mask"

                    # Step 3: Apply the SLF mask to the DAT scan
                    masked_slf="$dat_folder/masked_DAT_slf.nii.gz"
                    fslmaths "$dat_scan" -mas "$aligned_slf_mask" "$masked_slf"

                    # Step 4: Compute mean intensity of the SLF mask
                    mean_slf=$(fslstats "$masked_slf" -M)
                    echo "✅ SLF Mean Intensity: $mean_slf"

                    # Step 5: Compute mean intensity for Occipital mask
                    occipital_mask="$dat_folder/rfOccipital.nii"
                    if [ -f "$occipital_mask" ]; then
                        fslmaths "$dat_scan" -mas "$occipital_mask" "$dat_folder/masked_DAT_occipital.nii.gz"
                        mean_occipital=$(fslstats "$dat_folder/masked_DAT_occipital.nii.gz" -M)
                        echo "✅ Occipital Mean: $mean_occipital"
                    else
                        mean_occipital="N/A"
                        echo "⚠️ Occipital Mask Not Found for $patient_id ($session)"
                    fi

                    # Step 6: Compute mean intensity for each Striatum subregion
                    striatum_dir=$(find "$dat_folder" -maxdepth 1 -type d -name "Striatum_Regions_*" | head -n 1) 
                    if [ -n "$striatum_dir" ]; then
                        declare -a mean_striatum
                        for i in {1..7}; do
                            subregion_mask="$striatum_dir/${patient_id}_T1_striatum_subregion_bin_${i}.nii.gz"
                            masked_output="$dat_folder/masked_DAT_striatum_${i}.nii.gz"

                            if [ -f "$subregion_mask" ]; then
                                # Align subregion mask to DAT scan
                                aligned_striatum_mask="$dat_folder/striatum_subregion_${i}_aligned.nii.gz"
                                flirt -in "$subregion_mask" \
                                      -ref "$dat_scan" \
                                      -out "$aligned_striatum_mask" \
                                      -applyxfm -usesqform -interp nearestneighbour

                                # Ensure binary mask
                                fslmaths "$aligned_striatum_mask" -bin "$aligned_striatum_mask"

                                # Apply mask to DAT scan
                                fslmaths "$dat_scan" -mas "$aligned_striatum_mask" "$masked_output"

                                # Compute mean intensity for this subregion
                                mean_striatum[$((i-1))]=$(fslstats "$masked_output" -M)
                                echo "✅ Striatum Subregion $i Mean: ${mean_striatum[$((i-1))]}"
                            else
                                mean_striatum[$((i-1))]="N/A"
                                echo "⚠️ Subregion $i Mask Not Found for $patient_id ($session)"
                            fi
                        done

                        # Save results in CSV
                        echo "$patient_id,$session,$mean_slf,$mean_occipital,${mean_striatum[0]},${mean_striatum[1]},${mean_striatum[2]},${mean_striatum[3]},${mean_striatum[4]},${mean_striatum[5]},${mean_striatum[6]}" >> "$output_file"
                    else
                        echo "⚠️ No Striatum Regions Found for $patient_id ($session)"
                    fi

                else
                    echo "🚫 SCAN_A.nii not found for $patient_id in $dat_folder"
                fi
            fi
        done
    fi
done

echo "✅ Mean intensity values saved to: $output_file"

