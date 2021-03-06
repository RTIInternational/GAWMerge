#!/bin/bash
# Rsq_Calc 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {

    echo "Value of dose_file: '$dose_file'"
	echo "Value of ncases: '$ncases'"
    echo "Value of output_prefix: '$output_prefix'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    dx download "$dose_file" -o dose_file.gz

    # Fill in your application code here.
	echo -e "SNP\tInfo\tMAF\tRsq_all\tRsq_Array\tRsq_WGS" > $output_prefix
	awk -v Ncases=$ncases '/^#/ {next} {ds_all=0;ds2_all=0;count_all=0;
	                  ds_wgs=0;ds2_wgs=0;count_wgs=0;
					  ds_array=0;ds2_array=0;count_array=0;
                      for(i=10;i<=Ncases+9;i++){
						split($i,dose,":");
						count_all=count_all+1;ds_all=ds_all+dose[2];ds2_all=ds2_all+dose[2]^2;
						count_wgs=count_wgs+1;ds_wgs=ds_wgs+dose[2];ds2_wgs=ds2_wgs+dose[2]^2;}
					  for(i=Ncases+10;i<=NF;i++){
						split($i,dose,":");
						count_all=count_all+1;ds_all=ds_all+dose[2];ds2_all=ds2_all+dose[2]^2;
						count_array=count_array+1;ds_array=ds_array+dose[2];ds2_array=ds2_array+dose[2]^2;} 
        dsmean=ds_all/count_all;ds2mean=ds2_all/count_all;
        if(dsmean==0) rsq=0.00000; else if(dsmean==2) rsq=0.0000; else rsq=(ds2mean - dsmean^2)/(2*(dsmean/2)*(1-dsmean/2));
        dsmean_wgs=ds_wgs/count_wgs;ds2mean_wgs=ds2_wgs/count_wgs;
        if(dsmean_wgs==0) rsq_wgs=0.00000; else if(dsmean_wgs==2) rsq_wgs=0.0000; else rsq_wgs=(ds2mean_wgs - dsmean_wgs^2)/(2*(dsmean_wgs/2)*(1-dsmean_wgs/2));
        dsmean_array=ds_array/count_array;ds2mean_array=ds2_array/count_array;
        if(dsmean_array==0) rsq_array=0.00000; else if(dsmean_array==2) rsq_array=0.0000; else rsq_array=(ds2mean_array - dsmean_array^2)/(2*(dsmean_array/2)*(1-dsmean_array/2));
		split($8,infos,";");split(infos[2],maf,"=");
        print $3"\t"$8"\t"maf[2]"\t"rsq"\t"rsq_array"\t"rsq_wgs;}' \
        <(zcat dose_file.gz) \
		>> $output_prefix
    #
    # To report any recognized errors in the correct format in
    # $HOME/job_error.json and exit this script, you can use the
    # dx-jobutil-report-error utility as follows:
    #
    #   dx-jobutil-report-error "My error message"
    #
    # Note however that this entire bash script is executed with -e
    # when running in the cloud, so any line which returns a nonzero
    # exit code will prematurely exit the script; if no error was
    # reported in the job_error.json file, then the failure reason
    # will be AppInternalError with a generic error message.

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    mkdir -p out/results
	mv ${output_prefix} out/results/

    dx-upload-all-outputs
}
