module CardUtils

export ps2pdf

# Converts PostScript files to PDF files.
# Requires GhostScript to be installed and the `ps2pdf` utility to be in the
# program's $PATH.
ps2pdf(ps) = open(`ps2pdf - -`, read=true, write=true) do
  write(proc.in, ps)
  close(proc.in)
  read(proc.out, String) 
end

end
