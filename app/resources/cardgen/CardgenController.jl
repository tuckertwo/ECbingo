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

gencard_ps(id, round) = mk_card(gen_rand_array(MersenneTwister(stripcheck(id))),
  round_colors[round], num=id, round=round)

gencard_pdf = ps2pdf ∘ gencard_ps

gencard_rg(gc, type) = () -> verhoeff_verify(payload(:id)) ?
  wrap_contenttype(gc(payload(:id), payload(:round)), type) :
  Router.error("This card's check digit is bad; it can't possibly exist",
               "text/html", Val(404))

gencard_ps_r    = gencard_rg(gencard_ps,  "application/postscript")
gencard_pdf_r   = gencard_rg(gencard_pdf, "application/pdf")

genseq_rg(sym)   = () -> redirect(sym,
                                  id=verhoeff_gencheck(numgen()),
                                  round=payload(:round))

addcheck_rg(sym) = () -> redirect(sym,
                                  id=verhoeff_gencheck(payload(:id)),
                                  round=payload(:round))
end
