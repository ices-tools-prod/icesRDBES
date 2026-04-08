type_filters <- list(
  # Commercial Sampling (Hierarchies H1, H2, H3, H4, H5, H6, H7, H8, H9, H10,H11, H12,H13)
  CS = list(
    hierarchies = list("H1"),
    csFilters = list(
      deYear            = list("2024"),
      sdCountry         = list("ZW"),
      deSamplingScheme  = list(),
      deStratumName     = list(""),
      saSpeciesCode     = list(),
      foArea            = list(),
      leArea            = list()
    )
  ),

  # Commercial Landing (Hierarchy HCL)
  CL = list(
    hierarchies = list("HCL"),
    clFilters = list(
      clYear              = list("2024"),
      clVesselFlagCountry = list("ZW"),
      clArea              = list(),
      clSpeciesCode       = list()
    )
  ),

  # Commercial Effort (Hierarchy HCE)
  CE = list(
    hierarchies = list("HCE"),
    ceFilters = list(
      ceYear              = list("2024"),
      ceVesselFlagCountry = list("ZW"),
      ceArea              = list()
    )
  ),

  # Species List (Hierarchy HSL)
  SL = list(
    hierarchies = list("HSL"),
    slFilters = list(
      slYear            = list("2024"),
      slCountry         = list("ZW"),
      slSpeciesListName = list(""),
      slCatchFraction   = list()
    )
  ),

  # Vessel Details (Hierarchy HVD)
  VD = list(
    hierarchies = list("HVD"),
    vdFilters = list(
      vdYear    = list("2024"),
      vdCountry = list("ZW")
    )
  )
)
