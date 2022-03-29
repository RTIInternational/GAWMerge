<!-- dx-header -->
# Phasing genotype data (DNAnexus Platform App)

This is the source code for an app that runs ShapeIt2 (https://mathgen.stats.ox.ac.uk/genetics_software/shapeit/shapeit.html) on the DNAnexus Platform. For more information about how to run or modify it, see https://wiki.dnanexus.com/.

## Inputs
The inputs for the app include:
- input_prefix=file path to the extracted plink format files of the WGS or Array genotyping data
- input_map: genetic map used for the phasing (please note the desired genome build should be used. In all GAWMerge development we have used the b37 genome build).
- output_prefix: prefix that all output files will have
- thread: number of threads to use (recommend using 16)
- effective_size: effective size for the phasing

## Example applet call
```bash
for chr in {1..22}
do
echo $chr
dx run /Analyses/COPD_correlation/shapeit2 \
    -iinput_prefix="${projectName}:${dataDir}/cogend.chr${chr}.Freeze6a.copdgene.aa.extraction.qc.workflow.PASSOnly.DupsRemoved.b37.aa.missing.hw_p_gte_1e-4" \
    -iinput_map="${projectName}:${dataDir}/genetic_map_chr${chr}_combined_b37.txt" \
    -ioutput_prefix="cogend.copdgeneAA.b37.for_imputation.chr${chr}.phased" \
    -ithread=16 \
    -ieffective_size=15000 \
    -y
done
```


