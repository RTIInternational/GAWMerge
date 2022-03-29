 # Whole Genome Sequencing (WGS) Extraction and Quality Control (QC) Workflow

## Description
This workflow extracts the desired samples from the TOPMed WGS data and conducts the quality control steps. The workflow is a combination of two applets (1. Extract Variants and Samples from BCF files, and 2. Quality Control). The results of the 1st applet (extracted BCF file) is inputed into the QC applet.

## Input Parameters - Extract Variants
Input parameters for the applet to extract variants from the TOPMed BCF files are:
- input_bcf_file: The TOPMed BCF file for the cohort(s) desired to use as public controls
- input_csi_file: The TOPMed bcf.csi file for the cohort(s) desired to use as public controls
- sample_file: list of sample IDs to extract from the BCF files
- snp_file: list of SNP IDs to extract (note this should be the overlap of SNPs with the Array genotyping data desired to integrate with the TOPMed WGS data
- output_prefix: prefix for all output files

## Input Parameters - QC
Input parameters for the applet to conduct QC are:
- sample_keep: list of sample IDs to keep
- chr: the genomic chromosome to analyze
- b38_SNPs: b38 genomic position mapping file
- b37_chromosomes: b37 genomic chromosomes mapping file
- b37_positions: b37 genomic positions mapping file
- b37_rsID: b37 dbSNP rsID mapping file
- output_prefix: prefix for all output files

### QC Steps
The QC steps taken by this applet include:
- Samples failing sex check or with >3% missing data excluded
- Remove SNPs with missing rate >3%
- Remove SNPs which failed Hardy-Weinberg Equilibrium (p < 1e-4)
- Remove saples which were miss-classified with a 1000 genomes structure analysis
- Standard TOPMed QC metrics including
    - Remove variants labeled as SVM (support vector machine score more negative than -0.5)
    - Remove variants labeled as CEN (falls in a centromeric region)
    - Remove variants labeled as DISC (more than 5 % Mendelian inconsistencies)
    - Remove variants labeled as EXHET (excessive heterozygosity with HWE p-value < 1e-6)
    - Remove variants labeled as CHRXHET (excessive heterozygosity in male chr X)

## Example Workflow Call

```bash
# on a cloud Workstation spawned through DNAnexus
# predefine environmental variables: qcOutputDir, projectName, dataDir
dx cd $qcOutputDir
for chr in {1..22}
do
echo $chr
# Run Workflow for WGS Extraction, and QC
dx run /Analyses/wgs_extraction_qc \
    -istage-FfqXxVj0p56KJ1Qq2KFxkgqf.input_bcf_file="${projectName}:${dataDir}/freeze.6a.chr${chr}.pass_and_fail.gtonly.minDP10.bcf" \
    -istage-FfqXxVj0p56KJ1Qq2KFxkgqf.input_csi_file="${projectName}:${dataDir}/freeze.6a.chr${chr}.pass_and_fail.gtonly.minDP10.bcf.csi" \
    -istage-FfqXxVj0p56KJ1Qq2KFxkgqf.sample_file="${projectName}:${dataDir}/COPDGene_samples_Freeze6a" \
    -istage-FfqXxVj0p56KJ1Qq2KFxkgqf.snp_file="${projectName}:${dataDir}/cogend.aa.b138.b38.bed" \
    -istage-FfqXxVj0p56KJ1Qq2KFxkgqf.output_prefix="cogend.b138.b38.chr${chr}.Freeze6a.copdgeneALL" \
    -istage-Ffv9YPj0p563F6XkB7ggZ42z.sample_keep="${projectName}:${dataDir}/wgs_aa_kept.samples" \
    -istage-Ffv9YPj0p563F6XkB7ggZ42z.chr="${chr}" \
    -istage-Ffv9YPj0p563F6XkB7ggZ42z.b38_SNPs="${projectName}:${dataDir}/snp151.b38.chr${chr}" \
    -istage-Ffv9YPj0p563F6XkB7ggZ42z.b37_chromosomes="${projectName}:${dataDir}/snp151.b37.chr${chr}.chromosomes" \
    -istage-Ffv9YPj0p563F6XkB7ggZ42z.b37_positions="${projectName}:${dataDir}/snp151.b37.chr${chr}.positions" \
    -istage-Ffv9YPj0p563F6XkB7ggZ42z.b37_rsID="${projectName}:${dataDir}/snp151.b37.chr${chr}.rsID" \
    -istage-Ffv9YPj0p563F6XkB7ggZ42z.output_prefix="cogend.chr${chr}.Freeze6a.copdgene.aa.extraction.qc.workflow" \
    -y
done

```

