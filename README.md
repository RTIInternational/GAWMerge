# GAWMerge
Genotyping Array-WGS Merge, GAWMerge, is a protocol to combine genotypes from arrays and whole genome sequencing (WGS) in genome-wide association study (GWAS). One application of the GAWMerge protocol is to use WGS data as public controls for new GWAS with case-only cohorts. Therefor, WGS data from diverse samples like (TOPMed) can be used as public control with existing array genotyped data in GWAS.

The protocol has been implemented on the [DNANexus platform](https://www.dnanexus.com/) along with the [BioData Catalyst ecosystem](https://biodatacatalyst.nhlbi.nih.gov/). The [DNANexus protocol](https://github.com/RTIInternational/GAWMerge/blob/main/scripts/DNANexus/GAWMerge_protocol.md) and [BioData Catalyst](https://github.com/RTIInternational/GAWMerge/blob/main/scripts/BioData%20Catalyst/Identifying_Public_Controls_BDC.md) are described in detail within their markdown files.


## Test Data
To run GAWMerge you can use access controlled data (example dbGaP or TOPMed data), as used in our development. Furthermore, test data as VCF files from 1000 Genomes is made available for both [whole-genome sequencing (WGS)](https://github.com/RTIInternational/GAWMerge/blob/main/test_data/ALL.chr22.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.N100.vcf.gz) and [array genotyping](https://github.com/RTIInternational/GAWMerge/blob/main/test_data/ALL.chr22.omni_2123_samples_b37_SHAPEIT.20120103.snps.chip_based.haplotypes.N100.vcf.gz) data. The files within this Github are only a subset of all samples available on the [1000 genomes website](https://ftp-trace.ncbi.nih.gov/1000genomes/ftp/).
The output of GAWMerge is in compliance with GWAS Catalog standards. An [example](https://github.com/RTIInternational/GAWMerge/blob/main/test_data/true.positive.ea.aa.meta.filtered.chr15.table) of the available of our true positive experimentation presented within the original [publication](https://www.biorxiv.org/content/10.1101/2021.10.19.464854v1) is available within this GitHub. 


## Citation
Please cite the below manuscript for use of the GAWMerge protocol.

Mathur et al., Expanding the pool of public controls for GWAS via a method for combining genotypes from arrays and sequencing, bioRxiv 2021.10.19.464854; https://www.biorxiv.org/content/10.1101/2021.10.19.464854v1
