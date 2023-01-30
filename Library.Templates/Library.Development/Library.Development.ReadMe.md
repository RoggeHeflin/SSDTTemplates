# Data Flow
[raw (source)] -> [stg] -> normalize -> [fact] -> [calc] -> [rpt] (read only)

## Supporting schemas
[dim] Dimension or lookup schema objects
[doc] Documentation views
[track] Procedures for logging data into [Track.Svr] database


Data is pulled from earlier schemas to the target schema.
