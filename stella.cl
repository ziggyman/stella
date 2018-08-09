# --- STELLA -- Stella spectral reduction package

# Load necessary packages
noao
imred
ccdred
echelle

package stella

  task $fitsnozero   = "$foreign"
  task stzero        = "/rhome/aritter/prog/STELLA/stzero.cl"
  task stnflat       = "/rhome/aritter/prog/STELLA/stnflat.cl"
  task stsubzero     = "/rhome/aritter/prog/STELLA/stsubzero.cl"
  task stflat        = "/rhome/aritter/prog/STELLA/stflat.cl"
  task stdivflat     = "/rhome/aritter/prog/STELLA/stdivflat.cl"
  task stbadovertrim = "/rhome/aritter/prog/STELLA/stbadovertrim.cl"

clbye
