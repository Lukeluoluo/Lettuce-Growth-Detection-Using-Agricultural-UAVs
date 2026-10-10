#!/usr/bin/env Rscript

# ============================================================
# UAV ORTHOMOSAIC SINGLE-PLANT PHENOTYPING PIPELINE
#
# Processes BOTH:
#   1. RGB orthomosaics
#   2. Multispectral (MULTI) orthomosaics
#
# across all UAV flight dates / DAPs.
#
# IMPORTANT:
# Normally, another user only needs to change:
#
#   MAIN_DIR
#
# ------------------------------------------------------------
# EXPECTED DIRECTORY STRUCTURE
# ------------------------------------------------------------
#
# MAIN_DIR/
#
#   20250224_DAP26/
#       RGB/
#           orthomosaic.tif
#           shapefile.shp
#           shapefile.dbf
#           shapefile.shx
#           shapefile.prj
#
#       MULTI/
#           orthomosaic.tif
#           shapefile.shp
#           shapefile.dbf
#           shapefile.shx
#           shapefile.prj
#
#   20250303_DAP34/
#       RGB/
#       MULTI/
#
#   20250310_DAP41/
#       RGB/
#       MULTI/
#
#   ...
#
# ------------------------------------------------------------
# WORKFLOW
# ------------------------------------------------------------
#
# For each flight date:
#
#   RGB
#      ↓
#   Read orthomosaic + shapefile
#      ↓
#   CRS / overlap check
#      ↓
#   SHOW orthomosaic + polygons
#      ↓
#   USER CONFIRMS ALIGNMENT
#      ↓
#   HUE vegetation masking
#      ↓
#   PixelCount + RGB indices
#
#
#   MULTI
#      ↓
#   Read orthomosaic + shapefile
#      ↓
#   CRS / overlap check
#      ↓
#   SHOW orthomosaic + polygons
#      ↓
#   USER CONFIRMS ALIGNMENT
#      ↓
#   Use same-flight RGB image to create HUE vegetation mask
#      ↓
#   Transfer vegetation mask to MULTI
#      ↓
#   Multispectral indices
#
# ============================================================


rm(list = ls())


# ============================================================
# 0) PACKAGES
# ============================================================

suppressPackageStartupMessages({
  
  library(FIELDimageR)
  library(FIELDimageR.Extra)
  library(terra)
  library(sf)
  library(ggplot2)
  
})


# ============================================================
# 1) USER SETTING
# ============================================================
#
# Normally this is the ONLY path another user needs to change.
#
# ============================================================

MAIN_DIR <- "E:/Marul Ucus/Dryad_orthos"


if (!dir.exists(MAIN_DIR)) {
  
  stop(
    "MAIN_DIR does not exist:\n",
    MAIN_DIR
  )
  
}


# ============================================================
# 2) DATA TYPES TO PROCESS
# ============================================================

DATA_TYPES <- c(
  "RGB",
  "MULTI"
)


# ============================================================
# 3) BAND POSITIONS
# ============================================================
#
# RGB ORTHOMOSAIC
#
#   Band 1 = Red
#   Band 2 = Green
#   Band 3 = Blue
#
# ------------------------------------------------------------
#
# MULTI ORTHOMOSAIC
#
# Confirmed from the actual TIFF:
#
#   [1] "Green"
#   [2] "Red"
#   [3] "RedEdge"
#   [4] "NIR"
#
# Therefore:
#
#   Band 1 = Green
#   Band 2 = Red
#   Band 3 = Red Edge
#   Band 4 = NIR
#
# MULTI has NO BLUE band.
#
# ============================================================


# RGB
RGB_RED   <- 1
RGB_GREEN <- 2
RGB_BLUE  <- 3


# MULTI
MULTI_GREEN    <- 1
MULTI_RED      <- 2
MULTI_RED_EDGE <- 3
MULTI_NIR      <- 4


# ============================================================
# 4) OUTPUT DIRECTORY
# ============================================================

OUT_DIR <- file.path(
  MAIN_DIR,
  "outputs"
)


dir.create(
  OUT_DIR,
  showWarnings = FALSE,
  recursive = TRUE
)


# ============================================================
# 5) FIND ALL FLIGHT / DAP FOLDERS
# ============================================================

flight_folders <- list.dirs(
  MAIN_DIR,
  recursive = FALSE,
  full.names = TRUE
)


# Keep only folders such as:
#
# 20250224_DAP26
# 20250303_DAP34
# 20250310_DAP41
# etc.

flight_folders <- flight_folders[
  grepl(
    "^[0-9]{8}_DAP[0-9]+$",
    basename(flight_folders)
  )
]


flight_folders <- sort(
  flight_folders
)


if (length(flight_folders) == 0) {
  
  stop(
    "No flight folders matching YYYYMMDD_DAPxx ",
    "were found inside MAIN_DIR."
  )
  
}


cat("\n")
cat("====================================================\n")
cat("FLIGHT FOLDERS FOUND\n")
cat("====================================================\n")


for (x in flight_folders) {
  
  cat(
    " - ",
    basename(x),
    "\n",
    sep = ""
  )
  
}


cat("====================================================\n\n")


# ============================================================
# HELPER FUNCTION:
# FIND ONE TIFF
# ============================================================

find_one_tif <- function(folder) {
  
  
  tif_files <- list.files(
    folder,
    pattern = "\\.(tif|tiff)$",
    full.names = TRUE,
    ignore.case = TRUE
  )
  
  
  if (length(tif_files) == 0) {
    
    return(NULL)
    
  }
  
  
  if (length(tif_files) > 1) {
    
    stop(
      "\nMore than one TIFF found in:\n",
      folder,
      "\n\nFiles:\n",
      paste(
        basename(tif_files),
        collapse = "\n"
      ),
      "\n\nPlease keep only the intended orthomosaic TIFF ",
      "in this folder."
    )
    
  }
  
  
  tif_files[1]
  
}


# ============================================================
# HELPER FUNCTION:
# FIND ONE SHAPEFILE
# ============================================================

find_one_shp <- function(folder) {
  
  
  shp_files <- list.files(
    folder,
    pattern = "\\.shp$",
    full.names = TRUE,
    ignore.case = TRUE
  )
  
  
  if (length(shp_files) == 0) {
    
    return(NULL)
    
  }
  
  
  if (length(shp_files) > 1) {
    
    stop(
      "\nMore than one shapefile found in:\n",
      folder,
      "\n\nFiles:\n",
      paste(
        basename(shp_files),
        collapse = "\n"
      )
    )
    
  }
  
  
  shp_files[1]
  
}


# ============================================================
# HELPER FUNCTION:
# CLEAN + MATCH SHAPEFILE CRS
# ============================================================

prepare_shapes <- function(shps, raster) {
  
  
  # Remove empty geometries
  shps <- shps[
    !sf::st_is_empty(shps),
  ]
  
  
  # Fix invalid geometries
  if (any(!sf::st_is_valid(shps))) {
    
    message(
      "Invalid polygon geometries detected. Fixing..."
    )
    
    
    shps <- sf::st_make_valid(
      shps
    )
    
  }
  
  
  if (nrow(shps) == 0) {
    
    stop(
      "No valid plant polygons remain."
    )
    
  }
  
  
  # Check shapefile CRS
  if (is.na(sf::st_crs(shps))) {
    
    stop(
      "Shapefile does not contain a valid CRS."
    )
    
  }
  
  
  # Check raster CRS
  if (is.na(sf::st_crs(raster))) {
    
    stop(
      "Orthomosaic does not contain a valid CRS."
    )
    
  }
  
  
  # Transform shapefile if necessary
  if (sf::st_crs(shps) != sf::st_crs(raster)) {
    
    
    message(
      "CRS differs. Transforming shapefile ",
      "to orthomosaic CRS..."
    )
    
    
    shps <- sf::st_transform(
      shps,
      sf::st_crs(raster)
    )
    
    
  } else {
    
    
    message(
      "CRS check: OK."
    )
    
  }
  
  
  shps
  
}


# ============================================================
# HELPER FUNCTION:
# CHECK SPATIAL OVERLAP
# ============================================================

check_overlap <- function(raster, shps_v) {
  
  
  overlap_extent <- try(
    
    terra::intersect(
      terra::ext(raster),
      terra::ext(shps_v)
    ),
    
    silent = TRUE
    
  )
  
  
  if (
    inherits(overlap_extent, "try-error") ||
    is.null(overlap_extent)
  ) {
    
    return(FALSE)
    
  }
  
  
  TRUE
  
}


# ============================================================
# HELPER FUNCTION:
# VISUAL ALIGNMENT CONFIRMATION
#
# IMPORTANT:
# - Preview only: reduced resolution for fast display.
# - Full-resolution raster remains unchanged for extraction.
# - Uses the normal R/RStudio plotting device.
# ============================================================

confirm_alignment <- function(
    raster,
    shps,
    flight_name,
    data_type
) {
  
  cat("\n")
  cat("====================================================\n")
  cat("PRE-EXTRACTION ALIGNMENT CHECK\n")
  cat("====================================================\n")
  
  cat(
    "Flight : ",
    flight_name,
    "\n",
    sep = ""
  )
  
  cat(
    "Sensor : ",
    data_type,
    "\n",
    sep = ""
  )
  
  cat(
    "\nPreparing orthomosaic + shapefile preview...\n"
  )
  
  
  # ----------------------------------------------------------
  # 1) Convert shapefile to terra vector
  # ----------------------------------------------------------
  
  shps_v_preview <- terra::vect(shps)
  
  
  # ----------------------------------------------------------
  # 2) Crop raster to shapefile extent
  #
  # IMPORTANT:
  # Crop only. Do NOT mask here.
  # We want to see the orthomosaic underneath all polygons.
  # ----------------------------------------------------------
  
  preview <- terra::crop(
    raster,
    terra::ext(shps_v_preview)
  )
  
  
  # ----------------------------------------------------------
  # 3) Reduce resolution ONLY for display
  # ----------------------------------------------------------
  
  max_preview_cells <- 1000000
  
  total_cells <- terra::ncell(preview)
  
  
  if (total_cells > max_preview_cells) {
    
    fact_preview <- ceiling(
      sqrt(
        total_cells / max_preview_cells
      )
    )
    
    cat(
      "Large orthomosaic detected.\n",
      "Creating display-only preview (factor = ",
      fact_preview,
      ").\n",
      sep = ""
    )
    
    
    preview <- terra::aggregate(
      preview,
      fact = fact_preview,
      fun = mean,
      na.rm = TRUE
    )
    
  }
  
  
  # ----------------------------------------------------------
  # 4) Clear current plot
  # ----------------------------------------------------------
  
  if (grDevices::dev.cur() > 1) {
    
    graphics::plot.new()
    
  }
  
  
  # ----------------------------------------------------------
  # 5) Plot orthomosaic
  # ----------------------------------------------------------
  
  if (data_type == "RGB") {
    
    cat(
      "Displaying RGB orthomosaic...\n"
    )
    
    terra::plotRGB(
      preview,
      r = RGB_RED,
      g = RGB_GREEN,
      b = RGB_BLUE,
      stretch = "lin"
    )
    
    
  } else if (data_type == "MULTI") {
    
    cat(
      "Displaying MULTI as false color ",
      "(NIR / RedEdge / Green)...\n"
    )
    
    terra::plotRGB(
      preview,
      r = MULTI_NIR,
      g = MULTI_RED_EDGE,
      b = MULTI_GREEN,
      stretch = "lin"
    )
    
  }
  
  
  # ----------------------------------------------------------
  # 6) Add shapefile polygons ON TOP
  # ----------------------------------------------------------
  
  terra::plot(
    shps_v_preview,
    add = TRUE,
    border = "red",
    lwd = 1
  )
  
  
  # ----------------------------------------------------------
  # 7) Add title
  # ----------------------------------------------------------
  
  graphics::title(
    main = paste(
      flight_name,
      "|",
      data_type,
      "| Orthomosaic + single-plant polygons"
    )
  )
  
  
  # ----------------------------------------------------------
  # 8) Make sure plot is drawn before readline()
  # ----------------------------------------------------------
  
  grDevices::dev.flush()
  
  
  cat("\n")
  cat("----------------------------------------------------\n")
  cat("PLEASE CHECK THE PLOT WINDOW / RSTUDIO PLOTS PANE\n")
  cat("----------------------------------------------------\n")
  cat("The orthomosaic should now be visible.\n")
  cat("RED outlines = single-plant shapefile polygons.\n")
  cat("Check that the polygons correctly cover the plants.\n")
  
  
  if (data_type == "MULTI") {
    
    cat(
      "NOTE: MULTI is shown as false color only for ",
      "this visual alignment check.\n"
    )
    
  }
  
  
  cat(
    "\nThe ORIGINAL full-resolution raster will be used ",
    "for extraction.\n"
  )
  
  
  # ----------------------------------------------------------
  # 9) User confirmation
  # ----------------------------------------------------------
  
  repeat {
    
    answer <- readline(
      paste0(
        "\nIs the orthomosaic-shapefile alignment correct?\n",
        "Enter y = YES, continue extraction\n",
        "Enter n = NO, skip this orthomosaic\n",
        "Enter q = QUIT all processing\n",
        "Your answer: "
      )
    )
    
    
    answer <- tolower(
      trimws(answer)
    )
    
    
    if (answer %in% c("y", "n", "q")) {
      
      break
      
    }
    
    
    cat(
      "\nPlease enter only y, n, or q.\n"
    )
    
  }
  
  
  return(answer)
  
}

# ============================================================
# HELPER FUNCTION:
# GENERATE RGB HUE VEGETATION MASK
#
# Used for:
#   - RGB itself
#   - corresponding MULTI image
#
# ============================================================

generate_rgb_hue_mask <- function(
    rgb_raster,
    rgb_shapes
) {
  
  
  rgb_shapes_v <- terra::vect(
    rgb_shapes
  )
  
  
  # Crop + polygon mask
  rgb_exact <- terra::mask(
    
    terra::crop(
      rgb_raster,
      rgb_shapes_v
    ),
    
    rgb_shapes_v
    
  )
  
  
  # HUE vegetation segmentation
  rgb_remsoil <- FIELDimageR::fieldMask(
    
    mosaic = rgb_exact,
    
    Red   = RGB_RED,
    Green = RGB_GREEN,
    Blue  = RGB_BLUE,
    
    index = "HUE"
    
  )
  
  
  # ----------------------------------------------------------
  # Create binary vegetation mask
  #
  # Vegetation = 1
  # Background / soil = NA
  # ----------------------------------------------------------
  
  vegetation_mask <- rgb_remsoil$newMosaic[[1]]
  
  
  vegetation_mask <- terra::ifel(
    
    !is.na(vegetation_mask),
    
    1,
    
    NA
    
  )
  
  
  list(
    
    exact = rgb_exact,
    
    remsoil = rgb_remsoil$newMosaic,
    
    mask = vegetation_mask
    
  )
  
}


# ============================================================
# 6) MAIN LOOP: FLIGHT DATE / DAP
# ============================================================

for (flight_folder in flight_folders) {
  
  
  flight_name <- basename(
    flight_folder
  )
  
  
  cat("\n\n")
  cat("####################################################\n")
  cat("FLIGHT: ", flight_name, "\n", sep = "")
  cat("####################################################\n")
  
  
  # ==========================================================
  # 7) SECOND LOOP: RGB AND MULTI
  # ==========================================================
  
  for (DATA_TYPE in DATA_TYPES) {
    
    
    cat("\n")
    cat("====================================================\n")
    
    cat(
      "PROCESSING: ",
      flight_name,
      " | ",
      DATA_TYPE,
      "\n",
      sep = ""
    )
    
    cat("====================================================\n")
    
    
    # --------------------------------------------------------
    # Sensor directory
    # --------------------------------------------------------
    
    data_dir <- file.path(
      flight_folder,
      DATA_TYPE
    )
    
    
    if (!dir.exists(data_dir)) {
      
      warning(
        DATA_TYPE,
        " directory not found for ",
        flight_name,
        ". Skipping."
      )
      
      next
      
    }
    
    
    # ========================================================
    # 8) FIND TIFF
    # ========================================================
    
    mosaic_tif <- find_one_tif(
      data_dir
    )
    
    
    if (is.null(mosaic_tif)) {
      
      warning(
        "No TIFF found in:\n",
        data_dir
      )
      
      next
      
    }
    
    
    # ========================================================
    # 9) FIND SHAPEFILE
    # ========================================================
    
    shp_file <- find_one_shp(
      data_dir
    )
    
    
    if (is.null(shp_file)) {
      
      warning(
        "No shapefile found in:\n",
        data_dir
      )
      
      next
      
    }
    
    
    cat("\nOrthomosaic:\n")
    
    cat(
      "  ",
      basename(mosaic_tif),
      "\n",
      sep = ""
    )
    
    
    cat("\nShapefile:\n")
    
    cat(
      "  ",
      basename(shp_file),
      "\n",
      sep = ""
    )
    
    
    # ========================================================
    # 10) READ DATA
    # ========================================================
    
    EX1 <- terra::rast(
      mosaic_tif
    )
    
    
    shps <- sf::st_read(
      shp_file,
      quiet = TRUE
    )
    
    
    cat(
      "\nNumber of raster bands: ",
      terra::nlyr(EX1),
      "\n",
      sep = ""
    )
    
    
    cat(
      "Number of plant polygons: ",
      nrow(shps),
      "\n",
      sep = ""
    )
    
    
    cat(
      "\nRaster layer names:\n"
    )
    
    
    print(
      names(EX1)
    )
    
    
    # ========================================================
    # 11) BAND CONFIGURATION CHECK
    # ========================================================
    
    if (DATA_TYPE == "RGB") {
      
      
      RED_BAND   <- RGB_RED
      GREEN_BAND <- RGB_GREEN
      BLUE_BAND  <- RGB_BLUE
      
      
      required_band <- max(
        RED_BAND,
        GREEN_BAND,
        BLUE_BAND
      )
      
      
      if (terra::nlyr(EX1) < required_band) {
        
        stop(
          "\nRGB raster contains only ",
          terra::nlyr(EX1),
          " bands, but at least ",
          required_band,
          " are required."
        )
        
      }
      
      
    } else if (DATA_TYPE == "MULTI") {
      
      
      GREEN_BAND    <- MULTI_GREEN
      RED_BAND      <- MULTI_RED
      RED_EDGE_BAND <- MULTI_RED_EDGE
      NIR_BAND      <- MULTI_NIR
      
      
      required_band <- max(
        GREEN_BAND,
        RED_BAND,
        RED_EDGE_BAND,
        NIR_BAND
      )
      
      
      if (terra::nlyr(EX1) < required_band) {
        
        stop(
          "\nMULTI raster contains only ",
          terra::nlyr(EX1),
          " bands, but ",
          required_band,
          " are required."
        )
        
      }
      
      
      cat(
        "\nMULTI band configuration:\n",
        "  Green    = band ", GREEN_BAND, "\n",
        "  Red      = band ", RED_BAND, "\n",
        "  Red Edge = band ", RED_EDGE_BAND, "\n",
        "  NIR      = band ", NIR_BAND, "\n",
        sep = ""
      )
      
    }
    
    
    # ========================================================
    # 12) CLEAN SHAPES + CRS MATCH
    # ========================================================
    
    cat(
      "\nChecking shapefile geometry and CRS...\n"
    )
    
    
    shps <- prepare_shapes(
      shps,
      EX1
    )
    
    
    shps_v <- terra::vect(
      shps
    )
    
    
    # ========================================================
    # 13) SPATIAL OVERLAP CHECK
    # ========================================================
    
    cat(
      "Checking raster-shapefile spatial overlap...\n"
    )
    
    
    if (!check_overlap(EX1, shps_v)) {
      
      stop(
        "\nRaster and shapefile do not appear ",
        "to overlap spatially:\n",
        flight_name,
        " | ",
        DATA_TYPE
      )
      
    }
    
    
    message(
      "Spatial overlap check: OK."
    )
    
    
    # ========================================================
    # 14) VISUAL PRE-EXTRACTION CHECK
    # ========================================================
    #
    # Nothing will be extracted until the user confirms
    # alignment with "y".
    #
    # ========================================================
    
    alignment_answer <- confirm_alignment(
      
      raster = EX1,
      
      shps = shps,
      
      flight_name = flight_name,
      
      data_type = DATA_TYPE
      
    )
    
    
    # --------------------------------------------------------
    # Quit everything
    # --------------------------------------------------------
    
    if (alignment_answer == "q") {
      
      cat(
        "\nProcessing stopped by user.\n"
      )
      
      quit(
        save = "no"
      )
      
    }
    
    
    # --------------------------------------------------------
    # Skip this orthomosaic
    # --------------------------------------------------------
    
    if (alignment_answer == "n") {
      
      cat(
        "\nAlignment was not accepted. ",
        "Skipping:\n",
        flight_name,
        " | ",
        DATA_TYPE,
        "\n"
      )
      
      next
      
    }
    
    
    # --------------------------------------------------------
    # Continue
    # --------------------------------------------------------
    
    cat(
      "\nAlignment confirmed. ",
      "Starting data extraction...\n"
    )
    
    
    # ========================================================
    # 15) CROP + MASK TO PLANT POLYGONS
    # ========================================================
    
    cat(
      "\nCropping and masking orthomosaic ",
      "to single-plant polygons...\n"
    )
    
    
    EX1_exact <- terra::mask(
      
      terra::crop(
        EX1,
        shps_v
      ),
      
      shps_v
      
    )
    
    
    # ========================================================
    # 16) VEGETATION MASKING
    # ========================================================
    
    
    # --------------------------------------------------------
    # RGB
    # --------------------------------------------------------
    
    if (DATA_TYPE == "RGB") {
      
      
      cat(
        "Removing soil/background using RGB HUE...\n"
      )
      
      
      EX1_RemSoil <- FIELDimageR::fieldMask(
        
        mosaic = EX1_exact,
        
        Red   = RED_BAND,
        Green = GREEN_BAND,
        Blue  = BLUE_BAND,
        
        index = "HUE"
        
      )
      
      
      analysis_mosaic <- EX1_RemSoil$newMosaic
      
      
      # --------------------------------------------------------
      # MULTI
      # --------------------------------------------------------
      
    } else if (DATA_TYPE == "MULTI") {
      
      
      cat(
        "\nMULTI has no Blue band.\n"
      )
      
      cat(
        "Using corresponding RGB orthomosaic ",
        "to generate the HUE vegetation mask...\n"
      )
      
      
      # ------------------------------------------------------
      # Find corresponding RGB directory
      # ------------------------------------------------------
      
      rgb_dir <- file.path(
        flight_folder,
        "RGB"
      )
      
      
      if (!dir.exists(rgb_dir)) {
        
        stop(
          "\nCorresponding RGB directory was not found:\n",
          rgb_dir,
          "\n\nRGB imagery is required to create the ",
          "HUE vegetation mask for MULTI."
        )
        
      }


# ------------------------------------------------------
# Find RGB TIFF
# ------------------------------------------------------

rgb_tif <- find_one_tif(
  rgb_dir
)


      if (is.null(rgb_tif)) {
        
        stop(
          "\nNo corresponding RGB TIFF was found in:\n",
          rgb_dir
        )
        
      }   


# ------------------------------------------------------
# Read RGB
# ------------------------------------------------------

RGB_reference <- terra::rast(
  rgb_tif
)


# ------------------------------------------------------
# Use the current MULTI shapefile, transformed to RGB CRS
# ------------------------------------------------------

rgb_shapes <- shps


if (sf::st_crs(rgb_shapes) != sf::st_crs(RGB_reference)) {
  
  rgb_shapes <- sf::st_transform(
    rgb_shapes,
    sf::st_crs(RGB_reference)
  )
  
}


# ------------------------------------------------------
# Generate RGB HUE mask
# ------------------------------------------------------

rgb_mask_result <- generate_rgb_hue_mask(
  
  rgb_raster = RGB_reference,
  
  rgb_shapes = rgb_shapes
  
)


RGB_vegetation_mask <- rgb_mask_result$mask


# ------------------------------------------------------
# Transform MULTI crop if necessary
# ------------------------------------------------------
#
# Normally RGB and MULTI should already be georeferenced
# in the same coordinate system.
#
# ------------------------------------------------------

if (
  terra::crs(RGB_vegetation_mask) !=
  terra::crs(EX1_exact)
) {
  
  
  RGB_vegetation_mask <- terra::project(
    
    RGB_vegetation_mask,
    
    EX1_exact,
    
    method = "near"
    
  )
  
  
} else {
  
  
  # Match MULTI grid/resolution
  RGB_vegetation_mask <- terra::resample(
    
    RGB_vegetation_mask,
    
    EX1_exact,
    
    method = "near"
    
  )
  
}


# ------------------------------------------------------
# Apply RGB-derived vegetation mask to MULTI
# ------------------------------------------------------

analysis_mosaic <- terra::mask(
  
  EX1_exact,
  
  RGB_vegetation_mask
  
)


cat(
  "RGB-derived vegetation mask successfully ",
  "applied to MULTI.\n"
)

}


# ========================================================
# 17) CREATE OUTPUT DIRECTORIES
# ========================================================

sensor_out <- file.path(
  
  OUT_DIR,
  
  flight_name,
  
  DATA_TYPE
  
)


OUT_RAS <- file.path(
  sensor_out,
  "rasters"
)


OUT_TAB <- file.path(
  sensor_out,
  "tables"
)


OUT_FIG <- file.path(
  sensor_out,
  "figures"
)


dir.create(
  OUT_RAS,
  recursive = TRUE,
  showWarnings = FALSE
)


dir.create(
  OUT_TAB,
  recursive = TRUE,
  showWarnings = FALSE
)


dir.create(
  OUT_FIG,
  recursive = TRUE,
  showWarnings = FALSE
)


# ========================================================
# 18) SAVE VEGETATION-MASKED RASTER
# ========================================================

out_tif <- file.path(
  
  OUT_RAS,
  
  paste0(
    flight_name,
    "_",
    DATA_TYPE,
    "_VegetationMasked.tif"
  )
  
)


terra::writeRaster(
  
  analysis_mosaic,
  
  filename = out_tif,
  
  filetype = "GTiff",
  
  overwrite = TRUE
  
)


message(
  "Saved vegetation-masked raster: ",
  out_tif
)


# ========================================================
# 19) CANOPY PIXEL COUNT
# ========================================================

cat(
  "\nCalculating canopy PixelCount...\n"
)


EX1_Canopy <- FIELDimageR::fieldArea(
  
  mosaic = analysis_mosaic,
  
  fieldShape = shps
  
)


out_canopy_csv <- file.path(
  
  OUT_TAB,
  
  paste0(
    flight_name,
    "_",
    DATA_TYPE,
    "_PixelCount_Canopy.csv"
  )
  
)


# Remove spatial geometry before saving table
if (inherits(EX1_Canopy, "sf")) {
  
  EX1_Canopy <- sf::st_drop_geometry(
    EX1_Canopy
  )
  
}


write.csv(
  
  EX1_Canopy,
  
  out_canopy_csv,
  
  row.names = FALSE
  
)


message(
  "Saved canopy table: ",
  out_canopy_csv
)


# ========================================================
# 20) PIXELCOUNT HISTOGRAM
# ========================================================

if ("PixelCount" %in% names(EX1_Canopy)) {
  
  
  pixel_values <- EX1_Canopy$PixelCount[
    !is.na(EX1_Canopy$PixelCount) &
      EX1_Canopy$PixelCount >= 100
  ]
  
  
  if (length(pixel_values) > 0) {
    
    
    hist_png <- file.path(
      
      OUT_FIG,
      
      paste0(
        flight_name,
        "_",
        DATA_TYPE,
        "_PixelCount_hist.png"
      )
      
    )
    
    
    png(
      hist_png,
      width = 1600,
      height = 1200,
      res = 200
    )
    
    
    hist(
      
      pixel_values,
      
      main = "",
      
      xlab = "Pixel count",
      
      ylab = "Frequency"
      
    )
    
    
    dev.off()
    
    
    message(
      "Saved PixelCount histogram: ",
      hist_png
    )
    
  }
  
}


# ========================================================
# 21) VEGETATION INDICES
# ========================================================


# --------------------------------------------------------
# RGB INDICES
# --------------------------------------------------------

if (DATA_TYPE == "RGB") {
  
  
  cat(
    "\nCalculating RGB vegetation indices...\n"
  )
  
  
  EX1_Indices <- FIELDimageR::fieldIndex(
    
    mosaic = analysis_mosaic,
    
    Red   = RED_BAND,
    
    Green = GREEN_BAND,
    
    Blue  = BLUE_BAND
    
  )
  
  
  # --------------------------------------------------------
  # MULTISPECTRAL INDICES
  # --------------------------------------------------------
  
} else if (DATA_TYPE == "MULTI") {
  
  
  cat(
    "\nCalculating multispectral vegetation indices...\n"
  )
  
  
  EX1_Indices <- FIELDimageR::fieldIndex(
    
    mosaic = analysis_mosaic,
    
    Red = RED_BAND,
    
    Green = GREEN_BAND,
    
    RedEdge = RED_EDGE_BAND,
    
    NIR = NIR_BAND
    
  )
  
}


# ========================================================
# 22) CLEAN SHAPES FOR EXTRACTION
# ========================================================

shps2 <- shps[
  
  !sf::st_is_empty(shps) &
    
    sf::st_is_valid(shps),
  
]


# ========================================================
# 23) EXTRACT INDICES FOR EACH SINGLE PLANT
# ========================================================

cat(
  "Extracting indices for individual plants...\n"
)


EX1_Info <- FIELDimageR.Extra::fieldInfo_extra(
  
  mosaic = EX1_Indices,
  
  fieldShape = shps2,
  
  progress = TRUE
  
)


# ========================================================
# 24) SAVE INDEX TABLE
# ========================================================

out_indices_csv <- file.path(
  
  OUT_TAB,
  
  paste0(
    flight_name,
    "_",
    DATA_TYPE,
    "_Indices_fieldInfo.csv"
  )
  
)


# Remove spatial geometry before saving table
if (inherits(EX1_Info, "sf")) {
  
  EX1_Info <- sf::st_drop_geometry(
    EX1_Info
  )
  
}


write.csv(
  
  EX1_Info,
  
  out_indices_csv,
  
  row.names = FALSE
  
)


message(
  "Saved index table: ",
  out_indices_csv
)


# ========================================================
# 25) PREVIEW
# ========================================================

cat("\nPreview:\n")


print(
  head(
    EX1_Info,
    10
  )
)


# ========================================================
# 26) SENSOR COMPLETED
# ========================================================

cat("\n")
cat("----------------------------------------------------\n")

cat(
  "COMPLETED: ",
  flight_name,
  " | ",
  DATA_TYPE,
  "\n",
  sep = ""
)

cat("----------------------------------------------------\n")


# ========================================================
# 27) CLEAN MEMORY
# ========================================================

objects_to_remove <- c(
  
  "EX1",
  "EX1_exact",
  "analysis_mosaic",
  "EX1_Canopy",
  "EX1_Indices",
  "EX1_Info",
  "shps",
  "shps2",
  "shps_v"
  
)


for (obj in objects_to_remove) {
  
  if (exists(obj)) {
    
    rm(
      list = obj
    )
    
  }
  
}


# MULTI-specific temporary objects

multi_temp_objects <- c(
  
  "RGB_reference",
  "rgb_shapes",
  "rgb_mask_result",
  "RGB_vegetation_mask"
  
)


for (obj in multi_temp_objects) {
  
  if (exists(obj)) {
    
    rm(
      list = obj
    )
    
  }
  
}


# RGB-specific object

if (exists("EX1_RemSoil")) {
  
  rm(
    EX1_RemSoil
  )
  
}


gc()


      } # END RGB / MULTI LOOP
      
      
    } # END FLIGHT LOOP
    
    
    # ============================================================
    # 28) FINISHED
    # ============================================================
    
    cat("\n\n")
    cat("====================================================\n")
    cat("ALL FLIGHT DATES AND SENSOR TYPES COMPLETED\n")
    cat("====================================================\n")
    
    
    cat(
      "Outputs saved in:\n",
      OUT_DIR,
      "\n",
      sep = ""
    )
    
    
    cat("====================================================\n")
    
