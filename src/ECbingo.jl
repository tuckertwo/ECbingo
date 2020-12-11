module ECbingo

using Logging, LoggingExtras

function main()
  Base.eval(Main, :(const UserApp = ECbingo))

  include(joinpath("..", "genie.jl"))

  Base.eval(Main, :(const Genie = ECbingo.Genie))
  Base.eval(Main, :(using Genie))
end; main()

end
