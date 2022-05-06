d # Identifying Public Controls on NHLBI BioData Catalyst

Matching public controls to case-only cohorts is a standard epigemiologic approach. With this approach the analysis is able to control confounding factors and potentially cut costs. Successful application of public controls in genome-wide association studies (GWAS) requires (1) consistency in ancestry and substantial overlap in the genotyped variants between datasets.

The National Heart, Lung, and Blood Institute (NHLBI) funded Trans-omics for Precision Medicine (TOPMed) cohorts provide whole-genome sequencing (WGS) data with a diverse ancestry selection (60% non-European). 

## Matching Public Controls

BioData Catalyst is a NHLBI funded cloud-based ecosystem, which hosts the NHLBI TOPMed data. To match public controls from TOPMed to user provided case-only data, the GAWMerge protocol has been tested matching towards the TOPMed harmonized data. The TOPMed Consortium has harmonized over 100 variables related to heart, lung, blood, and sleep domains [ref]. The data for these variables are avilable on dbGaP and BioData Catalyst.

On BioData Catalyst the harmonized variables are accessed via:
- BioData Catalyst Powered by Gen3
- BioData Catalyst Powered by PIC-SURE

### Accessing Harmonized Variables - Gen3
BioData Catalyst Powered by Gen3 allows approved researchers to search and access harmonized datasets, where access is controlled by eRA commons login. Gen3 provides filterable categries (within the Project, Subject, and Harmonized Variables) to select the desired traits of the public controls. Below is an example where the criteria for public control select includes:
- COPDGene cohort
- European and African American races
- Current or Former Cigaretter Smoker
Using these filters shows that a total of 9,994 samples are selected, with their split of sex and race shown with the graphics.

The clinical data for these samples are easily exported to BioData Catalyst Powered by Seven Bridges using the 'Export All to Seven Bridges' button.

![BioData Catalyst Powered by Gen3](https://github.com/RTIInternational/GAWMerge/blob/main/scripts/BioData%20Catalyst/Screenshots/BDC_Gen3_search.PNG)


### Accessing Harmonized Variables - PIC-SURE
BioData Catalyst Powered by PIC-SURE allows researchers to explore both phenotypic and genetic data with interactive search and visualizations. The PIC-SURE data was interacted with the API within the BioData Catalyst Powered by Seven Bridges platform. A GUI interface is also available for PIC-SURE (more information available on [gitbook](https://bdcatalyst.gitbook.io/biodata-catalyst-documentation/written-documentation/getting-started/explore-available-data/pic-sure-for-biodata-catalyst-user-guide).
