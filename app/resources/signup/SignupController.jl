module SignupController

export route

using Genie, Genie.Router, Genie.Requests, Genie.Renderer, Genie.Renderer.Html
using Genie.Sessions
using UUIDs

route() = begin
#  sess = Sessions.session(Genie.Router.@params)
  html(:signup, :ph1, layout=:bstrap, title="Sign-up form")
end

end
