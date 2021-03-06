using Genie.Router
import CardgenController

route("/") do
  serve_static_file("welcome.html")
end

route("/gencard/:round::Int/:id::Int/card.ps",
      CardgenController.gencard_ps_r,
      named=:get_card_ps)
route("/gencard/:round::Int/:id::Int/card.pdf",
      CardgenController.gencard_pdf_r,
      named=:get_card_pdf)

route("/gencard/:round::Int/seq.ps",
      CardgenController.genseq_rg(:get_card_ps))
route("/gencard/:round::Int/seq.pdf",
      CardgenController.genseq_rg(:get_card_pdf))

route("/gencard/:round::Int/:id::Int/addcheck.ps",
      CardgenController.addcheck_rg(:get_card_ps))
route("/gencard/:round::Int/:id::Int/addcheck.pdf",
      CardgenController.addcheck_rg(:get_card_pdf))
