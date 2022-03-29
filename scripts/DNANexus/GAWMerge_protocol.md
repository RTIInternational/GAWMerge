 # GAWMerge General Protocol

**Note all the following analyses were conducted in DNAnexus**
1. All the commands staring with *dx* are from DNAnexus command line tool *dx-toolkit*;
2. The command *dx run* will launch an *App* created by DNAnexus *applet*, and we kept all the applets used in this protocol within the same folder.

## Case sample and public control selection

**Here is an example to combine COGEND AA with array-genotyped data and COPDGene AA with whole-genome sequencing (WGS) data**

## Extract SNPs and Samples from the WGS data
## QC case and control samples


1. Create BED File for the SNPs contained in the desired Array File
2. Input the BED file into liftover to receive the b38 coordinate for those SNPs

### Run WGS Data Extraction and QC Workflow

```bash
# on a cloud Workstation spawned through DNAnexus
# predefine environmental variables: qcOutputDir, projectName, dataDir
dx cd $qcOutputDir
for chr in {1..22}
do
echo $chr
# Run Workflow for WGS Extraction, and QC
dx run /GAWMerge/scripts/DNANexus/wgs_extraction_qc \
    -istage-FfqXxVj0p56KJ1Qq2KFxkgqf.input_bcf_file="<path_to_TOPMed_minDP10_bcf_file>" \
    -istage-FfqXxVj0p56KJ1Qq2KFxkgqf.input_csi_file="<path_to_TOPMed_minBP10_bcf_csi_file>" \
    -istage-FfqXxVj0p56KJ1Qq2KFxkgqf.sample_file="<path_to_samples_to_extract>" \
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

## Principal Component Analysis (PCA)
For the genome-wide association study (GWAS), PCA is conducted to include as covariates in the model.

### Genotype overlap between Array and WGS data
The overlap of SNPs are only analyzed for PCA. The overlap is conducted using PLINK and the docker image available on DockerHub (https://hub.docker.com/r/rtibiocloud/plink)
```bash
# This code is run on a DNANexus cloud workstation
# Merge QCed WGS Genome
mergeList="/home/dnanexus/fullGenome.txt"
for chr in {2..22}; do
    echo "/home/dnanexus/cogend.chr${chr}.Freeze6a.copdgene.aa.extraction.qc.workflow.PASSOnly.DupsRemoved.b37.aa.missing.hw_p_gte_1e-4" >> $mergeList
done
dx-docker run --rm -v /home/dnanexus:/home/dnanexus rtibiocloud/plink:1.9 plink \
    --bfile /home/dnanexus/cogend.chr1.Freeze6a.copdgene.aa.extraction.qc.workflow.PASSOnly.DupsRemoved.b37.aa.missing.hw_p_gte_1e-4 \
    --merge-list /home/dnanexus/fullGenome.txt \
    --make-bed \
    --out /home/dnanexus/cogend.genome.Freeze6a.copdgene.aa.extraction.qc.workflow.PASSOnly.DupsRemoved.b37.aa.missing.hw_p_gte_1e-4

# Overlap SNPs between WGS and Array Data
awk '{print $2}' /home/dnanexus/cogend.genome.Freeze6a.copdgene.aa.extraction.qc.workflow.PASSOnly.DupsRemoved.b37.aa.missing.hw_p_gte_1e-4.bim \
    > /home/dnanexus/wgs_snps
sort /home/dnanexus/wgs_snps > /home/dnanexus/wgs_snps_sort
 

awk '{print $2}' /home/dnanexus/cogend.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.bim \
    > /home/dnanexus/array_snps
sort /home/dnanexus/array_snps > /home/dnanexus/array_snps_sort

comm -12 /home/dnanexus/wgs_snps_sort /home/dnanexus/array_snps_sort \
    > /home/dnanexus/overlap_snps


dx-docker run --rm -v /home/dnanexus:/home/dnanexus rtibiocloud/plink:1.9 plink \
    --bfile /home/dnanexus/cogend.genome.Freeze6a.copdgene.aa.extraction.qc.workflow.PASSOnly.DupsRemoved.b37.aa.missing.hw_p_gte_1e-4 \
    --extract /home/dnanexus/overlap_snps \
    --make-bed \
    --out /home/dnanexus/cogend.genome.Freeze6a.copdgene.aa.extraction.qc.workflow.PASSOnly.DupsRemoved.b37.aa.missing.hw_p_gte_1e-4.overlap
dx-docker run --rm -v /home/dnanexus:/home/dnanexus rtibiocloud/plink:1.9 plink \
    --bfile /home/dnanexus/cogend.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss \
    --extract /home/dnanexus/overlap_snps \
    --make-bed \
    --out /home/dnanexus/cogend.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap


dx-docker run --rm -v /home/dnanexus:/home/dnanexus rtibiocloud/plink:1.9 plink \
    --bfile /home/dnanexus/cogend.genome.Freeze6a.copdgene.aa.extraction.qc.workflow.PASSOnly.DupsRemoved.b37.aa.missing.hw_p_gte_1e-4.overlap \
    --bmerge /home/dnanexus/cogend.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap \
    --make-bed \
    --out /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap
# Error: 122 variants with 3+ alleles present.
# For simplicity remove these 122 variants for PCA
dx-docker run --rm -v /home/dnanexus:/home/dnanexus rtibiocloud/plink:1.9 plink \
    --bfile /home/dnanexus/cogend.genome.Freeze6a.copdgene.aa.extraction.qc.workflow.PASSOnly.DupsRemoved.b37.aa.missing.hw_p_gte_1e-4.overlap \
    --exclude /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap-merge.missnp \
    --make-bed \
    --out /home/dnanexus/cogend.genome.Freeze6a.copdgene.aa.extraction.qc.workflow.PASSOnly.DupsRemoved.b37.aa.missing.hw_p_gte_1e-4.overlap.rm_multi_allelic
dx-docker run --rm -v /home/dnanexus:/home/dnanexus rtibiocloud/plink:1.9 plink \
    --bfile /home/dnanexus/cogend.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap \
    --exclude /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap-merge.missnp \
    --make-bed \
    --out /home/dnanexus/cogend.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic
dx-docker run --rm -v /home/dnanexus:/home/dnanexus rtibiocloud/plink:1.9 plink \
    --bfile /home/dnanexus/cogend.genome.Freeze6a.copdgene.aa.extraction.qc.workflow.PASSOnly.DupsRemoved.b37.aa.missing.hw_p_gte_1e-4.overlap.rm_multi_allelic \
    --bmerge /home/dnanexus/cogend.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic \
    --make-bed \
    --out /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic

dx upload /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic.*
```

### LD Prune
Linkage Disequilibrium (LD) pruning is conducted using PLINK via its Docker image on DockerHub (https://hub.docker.com/r/rtibiocloud/plink).

```bash
for chr in {1..22}; do
    echo $chr
    dx-docker run --rm -v /home/dnanexus:/home/dnanexus rtibiocloud/plink:1.9 plink \
        --bfile /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic \
        --indep-pairwise 50 5 0.5 \
        --out /home/dnanexus/cogendArray.copdgeneWGS.chr${chr}.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic.LDprune \
        --chr $chr
done

# Merge prune.in lists
cat /home/dnanexus/cogendArray.copdgeneWGS.chr*.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic.LDprune*.prune.in > \
    /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic.prune.in
# Extract prune.in SNPs
dx-docker run --rm -v /home/dnanexus:/home/dnanexus rticode/plink:1.9 plink \
    --bfile /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic \
    --extract /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic.prune.in \
    --make-bed \
    --out /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic.LDprune

dx upload /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic.LDprune.*
```

### Run PCA
Run PCA using PLINK via its Docker image on Dockerhub (https://hub.docker.com/r/rtibiocloud/plink).

```bash
dx-docker run --rm -v /home/dnanexus:/home/dnanexus rticode/plink:1.9 plink \
    --bfile /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic.LDprune \
    --pca \
    --out /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic.LDprune.pca

dx upload /home/dnanexus/cogendArray.copdgeneWGS.aa.snp_miss_lte_0.03.hw_p_gte_1e-4.het_hap_miss.overlap.rm_multi_allelic.LDprune.pca.*
```


## Phasing COGEND array and COPDGene WGS data seprately

### Run Phasing App

```python
dx cd $phasingOutputDir
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

## Merge phased data and Impute

```python
dx cd $mergeOutputDir
for chr in {1..22}
do
echo $chr
dx run /Analyses/merging_imputation \
    -istage-Fg6qpg00p56BX7ZxFFq1kgB4.WGS_phased_data="${projectName}:${dataDir}/cogend.copdgeneAA.b37.for_imputation.chr${chr}.phased.vcf" \
    -istage-Fg6qpg00p56BX7ZxFFq1kgB4.array_phased_data="${projectName}:${dataDir}/cogend.aa.chr${chr}.phased.vcf" \
    -istage-Fg6qpg00p56BX7ZxFFq1kgB4.output_prefix="cogend.aa.chr${chr}" \
    -istage-Fg6qpxQ0p569VfPZB3v4P2xx.ref_haps="${projectName}:${dataDir}/1000G.p3.v5.afr.chr${chr}.m3vcf.gz" \
    -istage-Fg6qpxQ0p569VfPZB3v4P2xx.format="GT,DS,GP" \
    -istage-Fg6qpxQ0p569VfPZB3v4P2xx.output_prefix="cogend.aa.imputed.chr${chr}" \
    -y
done
```

## Re-imputation

### Filter by Empirical R2


```python
dx cd $empE2OutputDir
for chr in {1..22};do
    ER2_cutoff=0.9
    dx run /Analyses/COPD_correlation/ER2_filter \
        -iinput_info_file="${projectName}:${dataDir}/cogend.aa.imputed.chr${chr}.info" \
        -iinput_phased_file="${projectName}:${dataDir}/cogend.aa.chr${chr}.for_imputation.phased.merged.hw_p_lt_1e-4.vcf.gz" \
        -iER2_cutoff=${ER2_cutoff} \
        -ioutput_prefix="cogend.aa.chr${chr}.for_imputation.phased.merged.hw_p_lt_1e-4.ER2_gt_${ER2_cutoff}" \
        -y
done
```

### Rerun imputation with bad Empirical R2 SNPs removed


```python
dx cd $reImputationOutputDir
for chr in {1..22}; do
    dx run /Analyses/COPD_correlation/minimac4 \
        -iref_haps="${projectName}:${dataDir}/1000G.p3.v5.afr.chr22.m3vcf.gz" \
        -iinput_haps="${projectName}:${dataDir}/cogend.aa.chr22.for_imputation.phased.merged.hw_p_lt_1e-4.ER2_gt_0.9.vcf.gz" \
        -iformat="GT,DS,GP" \
        -ioutput_prefix="cogend.aa.imputed.chr${chr}.ER2_gt_0.9" \
        -y
done
```

## Association test with rvTest


```python
dx cd $rvTest2OutputDir

for chr in {1..22}; do
    dx run /Analyses/COPD_correlation/rvTest_withCovar \
        -iinput_dose_vcf="${projectName}:${dataDir}/cogend.aa.imputed.chr${chr}.ER2_gt_0.9.dose.vcf.gz" \
        -iinput_pheno_ped="${projectName}:${dataDir}/pheno_cogend_aa_rvTest.ped" \
        -iinput_covar_ped="${projectName}:${dataDir}/cogendArray.copdWGS.AA.covars.ped" \
        -icovar_name="sex,EV1,EV2,EV3,EV4,EV5,EV6,EV7,EV8,EV9,EV10" \
        -ipheno_name="cogend" \
        -ioutput_prefix="cogend.aa.chr${chr}.ER2_gt_0.9.rvTest" \
        -y
done

```

## post association filtering

### Calculate Rsq for WGS and array data separately for this new imputed data


```python
dx cd $rsqReimputeOutputDir

for chr in {1..22}; do
    dx run /Analyses/COPD_correlation/Rsq_Calc \
        -idose_file="${projectName}:${dataDir}/cogend.aa.imputed.chr${chr}.ER2_gt_0.9.dose.vcf.gz" \
        -incases=712 \
        -ioutput_prefix="cogend.aa.imputed.chr${chr}.ER2_gt_0.9.info.rsq" \
        -y
done
```

### Filter results with MAF, R2 and Rsq_diff cutoffs


```python
dx cd $filteringFinalOutputDir

for chr in {1..22}; do
    dx run /Analyses/COPD_correlation/post_rvTest_allRsq \
        -iprefix_info_rsq="${projectName}:${dataDir}/cogend.aa.imputed.ER2_gt_0.9" \
        -iprefix_rvtest_assoc="${projectName}:${dataDir}/cogend.aa.ER2_gt_0.9" \
        -iarray_chr=22 \
        -imaf_cut=0.01 \
        -irsq_cut=0.8 \
        -irsq_diff_cut=0.1 \
        -ioutput_prefix=cogend.aa.ER2_filtered.chr22Test.rvTest.maf_gt_0.01_rsq_gt_0.8_rsq_diff_lt_0.1 \
        -y
done
```

### Plotting


```python
dx cd $plotFinalOutputDir

maf_cut=0.01
rsq_diff_cut=0.1
rsq_cut=0.8


dx run /Analyses/COPD_correlation/gwasPlot \
    -iinput_table="${projectName}:${dataDir}/cogend.aa.ER2_filtered.chr22Test.rvTest.maf_gt_${maf_cut}_rsq_gt_${rsq_cut}_rsq_diff_lt_${rsq_diff_cut}.table" \
    -ioutput_prefix="cogend.aa.ER2_filtered.chr22Test.rvTest.maf_gt_${maf_cut}_rsq_all_gt_${rsq_cut}_rsq_diff_lt_${rsq_diff_cut}.plots" \
    -y
```
