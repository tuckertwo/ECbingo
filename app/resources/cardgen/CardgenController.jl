module CardgenController
using Genie, Genie.Router, Genie.Requests, Genie.Renderer
using Cards, CardUtils, Verhoeff
using Random

const round_colors = ["maroon", "navy", "DarkMagenta"]

autoinc() = let i=-1; () -> i+=1 end
numgen = autoinc()

wrap_contenttype(data, type) = respond(WebRenderable(
    body=data,
    status=200,
    headers=Dict("Content-Type" => type)))

gencard_ps(id, round) = mk_card(gen_rand_array(MersenneTwister(id)),
  round_colors[round], num=id, round=round)

gencard_pdf = ps2pdf ∘ gencard_ps

gencard_ps_r() = wrap_contenttype(gencard_ps(payload(:id), payload(:round)),
                                  "application/postscript")

gencard_pdf_r() = wrap_contenttype(gencard_pdf(payload(:id), payload(:round)),
                                   "application/pdf")

genseq(sym) = () -> redirect(sym, id=numgen(), round=payload(:round))
end
