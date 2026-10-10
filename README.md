# Data and code from: High-throughput UAV phenomics and machine learning enables accurate early single-plant biomass prediction in lettuce

Dataset DOI: [10.5061/dryad.73n5tb3d4](https://doi.org/10.5061/dryad.73n5tb3d4)

## Description of the data and file structure

UAV RGB and Multispectral Orthomosaic Dataset, Single-Plant Shapefiles, Vegetation Indices, and Manual Phenotypic Measurements

1\. DATASET OVERVIEW

This dataset contains UAV-based RGB and multispectral imagery, orthomosaics, single-plant shapefiles, extracted image-derived traits, vegetation indices, and manually collected phenotypic measurements from a lettuce experiment.

The UAV imagery was collected at multiple developmental stages using a DJI Mavic 3 Multispectral (Mavic 3M) UAV. The experiment followed a randomized complete block design (RCBD) and included 1,080 individual plants. Each individual plant is represented by a unique PlotID. The single-plant shapefiles were prepared so that each polygon corresponds to one individual plant. Therefore, UAV-derived measurements can be connected with the experimental design and manually collected phenotypic measurements using the PlotID variable.

The submitted dataset consists of the following main files:

1\. Orthomosaics.zip

2\. df_all.txt

3\. Code for data extraction from ortho.R

2\. FILE DESCRIPTION

2.1. Orthomosaics.zip

Orthomosaics.zip contains the UAV orthomosaics and associated single-plant shapefiles for the different flight dates. After extraction, the main directory is organized according to flight date and days after planting (DAP). The included flight folders are:

* 20250224_DAP26
* 20250303_DAP34
* 20250310_DAP41
* 20250317_DAP48
* 20250320_DAP51
* 20250323_DAP54

The folder names follow the structure: YYYYMMDD_DAPXX

where:

YYYYMMDD = UAV flight date

DAPXX    = corresponding days after planting

3\. UAV DATA ACQUISITION

UAV imagery was acquired using a DJI Mavic 3 Multispectral (Mavic 3M). The dataset contains both:

\- RGB imagery

\- Multispectral imagery

Flights represented in the dataset were conducted primarily at 30 m flight altitude. For several developmental stages, additional data were also obtained at 20 m flight altitude. Consequently, some vegetation-index variables in df_all.txt contain either "_30m" or "_20m" in their names. The flight altitude is therefore explicitly included in the corresponding image-derived variable names.

4\. ORTHOMOSAIC DIRECTORY STRUCTURE

Each flight-date/DAP folder contains separate data for RGB and multispectral

(MULTI) imagery.

The general structure is:

Flight_Date_DAP/

|

\|-- RGB/

\|   |-- RGB orthomosaic

\|   |-- associated shapefile components

|

\|-- MULTI/

```
\|-- multispectral orthomosaic/band data

\|-- associated shapefile components
```

The RGB directory contains the RGB orthomosaic corresponding to that UAV flight. The MULTI directory contains the corresponding multispectral orthomosaic information. Associated shapefiles are included with the imagery and define the individual plant polygons used for extracting plant-level information.

5\. SINGLE-PLANT SHAPEFILES

The shapefiles define the spatial boundaries used for image-data extraction. Each polygon represents one individual plant in the field experiment. A total of 1,080 individual plants are represented in the experimental design.

The shapefiles therefore allow information from the orthomosaics to be extracted separately for every individual plant rather than summarizing measurements over an entire experimental plot containing multiple plants. Each plant polygon is associated with its corresponding PlotID.

PlotID is the primary identifier used to connect:

\- experimental design information,

\- individual plant identity,

\- RGB-derived traits,

\- multispectral-derived traits,

\- vegetation indices,

\- pixel counts,

\- and manually collected phenotypic measurements.

IMPORTANT:

A shapefile consists of multiple associated files (for example .shp, .shx, .dbf, .prj, etc.). These components should remain together in the same directory when the data are extracted and processed.

6\. df_all.txt

df_all.txt is the combined plant-level dataset.

Each row corresponds to an individual plant identified by PlotID.

The table combines:

1\. Experimental design information

2\. Manual phenotypic measurements

3\. UAV-derived RGB measurements

4\. UAV-derived multispectral measurements

5\. Vegetation indices

6\. Pixel-count information

The primary linking variable is:

PlotID

7\. EXPERIMENTAL DESIGN VARIABLES

The beginning of df_all.txt contains variables describing the experimental design and individual plant identity. These include:

PlotID: Unique identifier for each individual plant. This is the principal key  for linking the UAV-derived data with the experimental and phenotypic  information.

Rep: Replication in the experimental design.

Gen: Genotype identifier.

Blok: Block identifier.

Plant: Individual plant identifier within the corresponding experimental unit.

plot: Experimental plot information.

plantingDATE: Planting date.

8\. MANUALLY COLLECTED PHENOTYPIC VARIABLES

df_all.txt also contains manually collected plant measurements. These include:

* Leaf.number: Total number of fully developed leaves per individual plant at harvest (count; unitless).
* Weight: Fresh biomass of the individual lettuce plant measured at harvest (g plant⁻¹).
* SPAD1: First SPAD chlorophyll-related greenness measurement (SPAD unit; unitless index).
* SPAD2: Second SPAD chlorophyll-related greenness measurement (SPAD unit; unitless index).
* SPAD3: Third SPAD chlorophyll-related greenness measurement (SPAD unit; unitless index).
* Diameter1: First stem diameter measurement (cm).
* Diameter2: Second stem diameter measurement (cm).
* L: Leaf lightness (L*) measured using a Minolta Chroma Meter CR-400, ranging from 0 (black) to 100 (white; unitless).
* C: Leaf chroma (C*), representing color saturation, measured using a Minolta Chroma Meter CR-400 (unitless).
* h: Leaf hue angle (h°), representing the dominant leaf color, measured using a Minolta Chroma Meter CR-400 (degrees).
* A: Derived a* color coordinate calculated from the measured chroma (C*) and hue angle (h°), representing the green–red color axis (unitless).
* B: Derived b* color coordinate calculated from the measured chroma (C*) and hue angle (h°), representing the blue–yellow color axis (unitless).
* PixelCount_DAPxx_YYm: Number of vegetation-classified canopy pixels within the corresponding single-plant polygon at the specified DAP and flight altitude (pixel count; unitless).

9\. UAV-DERIVED VARIABLES

UAV-derived variables are identified by the following general naming convention: TRAIT_DAPXX_ALTITUDE

For example:

NDVI_DAP41_30m means:

NDVI    = Normalized Difference Vegetation Index

DAP41   = measurement derived from the flight at 41 days after planting

30m     = UAV flight altitude of 30 m

Another example is: VARI_DAP48_20m which represents the VARI vegetation index obtained from the UAV data collected at 48 days after planting and 20 m flight altitude.

10\. PIXEL COUNT VARIABLES

PixelCount variables contain the number of vegetation-classified image pixels associated with the corresponding individual plant after spatial extraction. PixelCount can therefore be interpreted as a canopy structural size indicator.

PixelCount = count of vegetation-classified pixels within the corresponding single-plant polygon.

Examples include:

* PixelCount_DAP26_30m
* PixelCount_DAP34_30m
* PixelCount_DAP34_20m
* PixelCount_DAP41_30m
* PixelCount_DAP41_20m
* PixelCount_DAP48_30m
* PixelCount_DAP48_20m
* PixelCount_DAP51_30m
* PixelCount_DAP51_20m
* PixelCount_DAP54_20m
* PixelCount_DAP54_30m

11\. VEGETATION INDEX CALCULATIONS

The following vegetation indices were calculated from RGB and/or multispectral spectral bands.

In the equations:

R   = Red band

G   = Green band

B   = Blue band

RE  = Red-edge band

NIR = Near-infrared band

11.1. RGB-BASED INDICES

* NGRDI – Normalized Green-Red Difference Index
* NGRDI = (G - R) / (G + R)
* Reference: Tucker (1979)
* GLI – Green Leaf Index
* GLI = (2G - R - B) / (2G + R + B)

Reference: Louhaichi et al. (2001)

* BI – Brightness Index
* BI = sqrt((R^2 + G^2 + B^2) / 3)
* Reference: Richardson and Wiegand (1977)
* ExG – Excess Green Index
* ExG = 2G - R - B
* Reference: Woebbecke et al. (1995)
* MExG – Modified Excess Green Index
* MExG = 1.262G - 0.884R - 0.311B
* Reference: Burgos-Artizzu et al. (2011)
* MGVRI – Modified Green-Red Vegetation Index
* MGVRI = (G^2 - R^2) / (G^2 + R^2)
* Reference: Bendig et al. (2015)
* CIVE – Color Index of Vegetation Extraction
* CIVE = 0.441R - 0.811G + 0.385B + 18.78745
* Reference: Kataoka et al. (2003)
* VEG – Vegetative Index
* VEG = G / (R^0.667 + B^0.334)
* Reference: Hague et al. (2006)
* VARI – Visible Atmospherically Resistant Index
* VARI = (G - R) / (G + R - B)

Reference: Gitelson et al. (2002)

11.2. MULTISPECTRAL INDICES

* NDVI – Normalized Difference Vegetation Index
* NDVI = (NIR - R) / (NIR + R)
* Reference: Tucker (1979)
* GNDVI – Green Normalized Difference Vegetation Index
* GNDVI = (NIR - G) / (NIR + G)
* Reference: Gitelson et al. (2002)
* NDRE – Normalized Difference Red Edge Index
* NDRE = (NIR - RE) / (NIR + RE)
* Reference: Tucker (1979)
* SAVI – Soil-Adjusted Vegetation Index
* SAVI = 1.5(NIR - R) / (NIR + R + 0.5)
* Reference: Huete (1988)
* MSR – Modified Simple Ratio
* MSR = ((NIR / R) - 1) / sqrt((NIR / R) + 1)
* Reference: Chen (1996)
* CIG – Chlorophyll Vegetation Index-Green
* CIG = (NIR / G) - 1

Reference: Gitelson et al. (2005)

* CIRE – Chlorophyll Vegetation Index-Red Edge
* CIRE = (NIR / RE) - 1
* Reference: Gitelson et al. (2005)
* CVI – Chlorophyll Vegetation Index
* CVI = (NIR × R) / G^2
* Reference: Vincini et al. (2008)
* GNREI – Normalized Difference Red Edge Green Index
* GNREI = (RE - G) / (RE + G)

Reference: Gitelson et al. (1996)

12\. RGB-BASED VEGETATION INDEX VARIABLES IN df_all.txt

The RGB-derived vegetation indices represented in df_all.txt include:

NGRDI

GLI

BI

ExG

MExG

MGVRI

CIVE

VEG

VARI

Each index is identified by the corresponding DAP and flight altitude.

Examples:

NGRDI_DAP26_30m

GLI_DAP41_30m

ExG_DAP48_20m

VARI_DAP54_30m

13\. MULTISPECTRAL VEGETATION INDEX VARIABLES IN df_all.txt

The multispectral-derived indices represented in df_all.txt include:

NDVI

GNDVI

NDRE

SAVI

MSR

CIG

CIRE

CVI

GNREI

Each index is identified by the corresponding DAP and flight altitude.

Examples:

NDVI_DAP26_30m

GNDVI_DAP34_20m

NDRE_DAP41_30m

SAVI_DAP48_20m

CIG_DAP51_30m

CIRE_DAP54_30m

14\. DEVELOPMENTAL STAGES / UAV FLIGHTS

The UAV data represent repeated measurements of the same experiment across plant development. The main developmental stages included are:

DAP26

DAP34

DAP41

DAP48

DAP51

DAP54

where DAP represents Days After Planting. The corresponding flight-date folders are:

* 20250224_DAP26
* 20250303_DAP34
* 20250310_DAP41
* 20250317_DAP48
* 20250320_DAP51
* 20250323_DAP54

This temporal structure allows changes in individual-plant spectral, structural, and image-derived characteristics to be investigated throughout plant development.

15\. FLIGHT ALTITUDES

The variable names also specify the UAV flight altitude. Two altitude identifiers occur in df_all.txt:

30m: Data collected from flights conducted at approximately 30 m.

20m: Data collected from additional flights conducted at approximately 20 m.

Not every DAP necessarily contains measurements at both altitudes. For example, DAP26 is represented by 30 m measurements, whereas several subsequent DAPs contain measurements from both 20 m and 30 m flights.

16\. Code for data extraction from ortho.R

"Code for data extraction from ortho.R" contains the R workflow used to extract individual-plant information from the supplied orthomosaics using the associated single-plant shapefiles.

The general workflow is:

1\. Read the UAV orthomosaic.

2\. Read the corresponding single-plant shapefile.

3\. Match/check the spatial information between the orthomosaic and shapefile.

4\. Extract image information separately for each single-plant polygon.

5\. Identify vegetation pixels within the individual-plant area.

6\. Calculate/summarize the corresponding RGB and/or multispectral image-derived information at the individual-plant level.

7\. Calculate the relevant vegetation indices.

8\. Retain the PlotID associated with each plant polygon.

9\. Export the resulting plant-level table.

The PlotID generated/retained by this extraction procedure allows the

resulting table to be directly linked to df_all.txt.

17\. LINKING THE R OUTPUT WITH df_all.txt

PlotID should be used as the key variable when combining newly extracted orthomosaic information with df_all.txt.

Conceptually:

```
           Orthomosaic

                \+

      Single-plant shapefile

                |

                |

                v

   R data-extraction workflow

                |

                v

      Plant-level output

         \[PlotID]

                |

                \|  merge/join by PlotID

                v

           df_all.txt

         \[PlotID]

                |

                v

   Complete phenotypic dataset
```

Therefore, the individual-plant measurements extracted using:

"Code for data extraction from ortho.R" can be aligned with the experimental design, vegetation indices, and manual phenotypic measurements already available in df_all.txt by matching PlotID.

18\. EXAMPLE OF DATA INTEGRATION IN R

An extracted table can be combined with df_all.txt using PlotID.

For example:

df_all <- read.delim(

"df_all.txt",

header = TRUE,

sep = "\t",

check.names = FALSE

)

extracted_data <- read.csv(

"extracted_data.csv"

)

combined_data <- merge(

df_all,

extracted_data,

by = "PlotID",

all.x = TRUE

)

Alternatively, using dplyr:

library(dplyr)

combined_data <- df_all %>%

left_join(

```
extracted_data,

by = "PlotID"
```

)

PlotID should be checked before joining to ensure that the plant identifiers are represented consistently in both datasets.

19\. DATA ORGANIZATION SUMMARY

The relationship among the submitted files can be summarized as follows:

Orthomosaics.zip

|

\|-- 20250224_DAP26

\|      |-- RGB

\|      |-- MULTI

|

\|-- 20250303_DAP34

\|      |-- RGB

\|      |-- MULTI

|

\|-- 20250310_DAP41

\|      |-- RGB

\|      |-- MULTI

|

\|-- 20250317_DAP48

\|      |-- RGB

\|      |-- MULTI

|

\|-- 20250320_DAP51

\|      |-- RGB

\|      |-- MULTI

|

\|-- 20250323_DAP54

```
   \|-- RGB

   \|-- MULTI
```

Each RGB/MULTI dataset is accompanied by the corresponding spatial information/shapefiles required for individual-plant extraction.

```
                       |

                       v

          Code for data extraction

                from ortho.R

                       |

                       v

         Individual-plant extraction

                 by PlotID

                       |

                       v

                 df_all.txt

                       |

      \-----------------------------------

      \|                |                |

      v                v                v
```

Experimental        Manual          UAV-derived

```
  design          phenotypes        variables
```

20\. IMPORTANT DATA-HANDLING NOTES

1\. PlotID is the main identifier connecting all individual-plant data.

2\. The shapefile components should not be separated. All associated shapefile files should remain together in their original directories.

3\. The original directory structure inside Orthomosaics.zip should preferably be retained because the folders identify flight date, DAP, sensor type, and associated spatial files.

4\. DAP in a variable name represents Days After Planting.

5\. The "_20m" and "_30m" suffixes indicate UAV flight altitude.

6\. RGB and multispectral measurements are stored separately in the orthomosaic directories but can be integrated at the plant level through PlotID.

7\. The same PlotID convention should be retained in any newly generated output files to ensure compatibility with df_all.txt.

8\. df_all.txt contains the integrated experimental dataset and can therefore be used as the principal table for subsequent statistical, phenotypic, temporal, or predictive analyses.

9\. PixelCount represents the number of vegetation-classified pixels within the corresponding single-plant polygon and provides an image-derived indicator of canopy structural size.

10\. Vegetation-index names include both developmental timing (DAP) and flight

```
altitude whenever applicable.
```

### Missing values

Missing or unavailable observations in `df_all.txt` are represented as `NA`.

An `NA` indicates that a valid measurement was not available for the corresponding individual plant and variable. Missing values may occur when a manual phenotypic measurement was not recorded or when a reliable UAV-derived value could not be extracted for a particular plant, flight date, sensor, or flight altitude. For example, image-derived measurements may be unavailable when the plant canopy could not be reliably identified or when valid vegetation pixels were not available within the corresponding single-plant polygon.

`NA` values should therefore be treated as missing observations and not as zero values. No numerical value was intentionally hidden or suppressed.

21\. ABBREVIATIONS

UAV     Unmanned Aerial Vehicle

RGB     Red, Green, Blue

MULTI   Multispectral

DAP     Days After Planting

RCBD    Randomized Complete Block Design

VI      Vegetation Index

SPAD SPAD chlorophyll-related greenness measurement

R       Red band

G       Green band

B       Blue band

RE      Red-edge band

NIR     Near-infrared band

NGRDI   Normalized Green-Red Difference Index

GLI     Green Leaf Index

BI      Brightness Index

ExG     Excess Green Index

MExG    Modified Excess Green Index

MGVRI   Modified Green-Red Vegetation Index

CIVE    Color Index of Vegetation Extraction

VEG     Vegetative Index

VARI    Visible Atmospherically Resistant Index

NDVI    Normalized Difference Vegetation Index

GNDVI   Green Normalized Difference Vegetation Index

NDRE    Normalized Difference Red Edge Index

SAVI    Soil-Adjusted Vegetation Index

MSR     Modified Simple Ratio

CIG     Chlorophyll Vegetation Index-Green

CIRE    Chlorophyll Vegetation Index-Red Edge

CVI     Chlorophyll Vegetation Index

GNREI   Normalized Difference Red Edge Green Index

22\. PRIMARY DATA LINKAGE

For all subsequent analyses, the fundamental relationship is:

```
                     PlotID

                       |

      \-----------------------------------

      \|                |                |

      v                v                v

Experimental       UAV-derived       Manual

   design             traits        phenotypes
```

Accordingly, PlotID should be treated as the unique plant-level identifier when combining or analyzing the supplied files.

23\. REFERENCES FOR VEGETATION INDICES

Bendig J, Yu K, Aasen H, Bolten A, Bennertz S, Broscheit J, Gnyp ML, Bareth G (2015) Combining UAV-based plant height from crop surface models, visible, and near infrared vegetation indices for biomass monitoring in barley. International Journal of Applied Earth Observation and Geoinformation 39:79-87 Burgos-Artizzu XP, Ribeiro A, Guijarro M, Pajares G (2011) Real-time image processing for crop/weed discrimination in maize fields. Computers and Electronics in Agriculture 75 (2):337-346. doi:[https://doi.org/10.1016/j.compag.2010.12.011](https://doi.org/10.1016/j.compag.2010.12.011)

Chen JM (1996) Evaluation of Vegetation Indices and a Modified Simple Ratio for Boreal Applications. Canadian Journal of Remote Sensing 22 (3):229-242. doi:10.1080/07038992.1996.10855178 Gitelson AA, Kaufman YJ, Merzlyak MN (1996) Use of a green channel in remote sensing of global vegetation from EOS-MODIS. Remote Sensing of Environment 58 (3):289-298. doi:[https://doi.org/10.1016/S0034-4257(96)00072-7](https://doi.org/10.1016/S0034-4257\(96\)00072-7)

Gitelson AA, Kaufman YJ, Stark R, Rundquist D (2002) Novel algorithms for remote estimation of vegetation fraction. Remote sensing of Environment 80 (1):76-87 Gitelson AA, Viña A, Ciganda V, Rundquist DC, Arkebauer TJ (2005) Remote estimation of canopy chlorophyll content in crops. Geophysical Research Letters 32 (8). doi:[https://doi.org/10.1029/2005GL022688](https://doi.org/10.1029/2005GL022688)

Hague T, Tillett N, Wheeler H (2006) Automated crop and weed monitoring in widely spaced cereals. Precision Agriculture 7 (1):21-32 Huete AR (1988) A soil-adjusted vegetation index (SAVI). Remote Sensing of Environment 25 (3):295-309. doi:[https://doi.org/10.1016/0034-4257(88)90106-X](https://doi.org/10.1016/0034-4257\(88\)90106-X)

Kataoka T, Kaneko T, Okamoto H, Hata S Crop growth estimation system using machine vision. In: Proceedings 2003 IEEE/ASME International Conference on Advanced Intelligent Mechatronics (AIM 2003), 20-24 July 2003 2003. pp b1079-b1083 vol.1072. doi:10.1109/AIM.2003.1225492

Louhaichi M, Borman MM, Johnson DE (2001) Spatially located platform and aerial photography for documentation of grazing impacts on wheat. Geocarto International 16 (1):65-70 Richardson AJ, Wiegand C (1977) Distinguishing vegetation from soil background information. Photogrammetric engineering and remote sensing 43 (12):1541-1552

Tucker CJ (1979) Red and photographic infrared linear combinations for monitoring vegetation. Remote sensing of Environment 8 (2):127-150 Vincini M, Frazzi E, D’Alessio P (2008) A broad-band leaf chlorophyll vegetation index at the canopy scale. Precision Agriculture 9 (5):303-319. doi:10.1007/s11119-008-9075-z

Woebbecke DM, Meyer GE, Von Bargen K, Mortensen DA (1995) Color indices for weed identification under various soil, residue, and lighting conditions. Transactions of the ASAE 38 (1):259-269

### Files and variables

**File:** **`Code_for_data_extraction_from_ortho.R`**\
**Description:** R script used to extract single-plant canopy pixel counts and RGB- and multispectral-based vegetation indices from UAV orthomosaics using the corresponding single-plant shapefiles.

**File:** **`df_all.txt`**\
**Description:** Final integrated phenotypic and UAV-derived dataset containing plant identifiers, experimental design information, manually measured plant traits, and single-plant image-derived traits collected across UAV flight dates and flight altitudes.

For example, **`NDVI_DAP41_30m`** represents NDVI measured **41 days after planting from the UAV flight conducted at 30 m above ground level**.

**File:** **`Orthomosaics.zip`**\
**Description:** Compressed archive containing the RGB and multispectral UAV orthomosaics acquired across the evaluated flight dates and flight altitudes, together with the corresponding single-plant shapefiles used for image-based trait extraction.

## Code/software

Data extraction and processing were performed in R. The submitted R script, Code_for_data_extraction_from_ortho.R, provides the workflow used to extract single-plant UAV-derived traits from the RGB and multispectral orthomosaics included in this dataset. The script requires the R packages FIELDimageR, FIELDimageR.Extra, terra, sf, and ggplot2.

The script automatically identifies the UAV flight-date folders and processes the corresponding RGB and multispectral (MULTI) orthomosaics and single-plant shapefiles. Before data extraction, shapefile geometries and coordinate reference systems (CRS) are checked, and the shapefiles are transformed to match the corresponding orthomosaic CRS when necessary. Spatial overlap between each orthomosaic and shapefile is also checked. A visual preview of the orthomosaic with the single-plant polygons is provided for confirmation of spatial alignment before extraction.

For RGB imagery, soil/background pixels are removed using HUE-based vegetation masking implemented with FIELDimageR. Canopy pixel counts and RGB-based vegetation indices are subsequently calculated for each individual plant polygon. The multispectral orthomosaics contain Green, Red, Red Edge, and near-infrared (NIR) bands. For multispectral processing, the vegetation mask generated from the corresponding RGB orthomosaic is transferred to the multispectral orthomosaic, after which multispectral vegetation indices are calculated and extracted for each individual plant polygon.

The script saves the resulting single-plant canopy pixel counts and vegetation-index measurements as CSV files. Users wishing to reproduce the extraction workflow should modify the MAIN_DIR variable at the beginning of the script to specify the location of the downloaded orthomosaic dataset on their local computer. The expected directory organization and processing workflow are documented within the R script.
