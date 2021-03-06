module CardUtils

using StatsBase

export ps2pdf, gen_rand_array

# Converts PostScript files to PDF files.
# Requires GhostScript to be installed and the `ps2pdf` utility to be in the
# program's $PATH.
ps2pdf(ps) = open(`ps2pdf - -`, read=true, write=true) do proc
  write(proc.in, ps)
  close(proc.in)
  read(proc.out, String) 
end

# TODO: Write tests
gen_rand_col(rng, yl, replace) = (r) -> sample(rng, r, yl, replace=replace)

# TODO: Write tests
gen_rand_array(rng; ranges=[01:15, 16:30, 31:45, 46:65, 66:75], yl=5,
               replace=false) = hcat(map(gen_rand_col(rng, yl, replace), ranges)...)

end
