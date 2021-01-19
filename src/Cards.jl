module Cards
# This module generates cards. Its contents will have to be changed to account
# for variations in the card template.

export mk_card

using Printf
using Dates
using Colors
using ColorTypes

# This function returns a function that converts linear indices to Cartesian (x
# and y) indices for the given array.
# Usage: map(ci_mapfunc(xs), collect(enumerate(xs)))
ci_mapfunc(xs) = ((li, x),) -> (CartesianIndices(xs)[li], x)

mk_gridcell((i, n)) = if i.I === (3,3) ""
  else @sprintf("%u %u gat moveto (%02u) show\n", i.I[2]-1, i.I[1]-1, n) end

mk_grid(ns) = map(mk_gridcell ∘ ci_mapfunc(ns), enumerate(ns))

handle_date(date::Nothing)        = ""
handle_date(date::Date)           = handle_date(Dates.format(date,
  dateformat"YYYY-mm-dd"))
handle_date(date::DateTime)       = handle_date(Date(date)) *
  handle_time(Time(date))
handle_date(date::AbstractString) = """
  3 -0.53 ga moveto
  (Date) show
  4 -0.53 ga moveto
  ($(date)) show
  """

handle_time(time::Nothing)        = ""
handle_time(time::Time)           = handle_time(Dates.format(time,
  dateformat"II:MM pp"))
handle_time(time::AbstractString) = """
  3 -0.64 ga moveto
  (Starting At) show
  4 -0.64 ga moveto
  ($(time)) show
  """

# The interface by which card details are passed to this function is subject
# to change.
# (I might make it a struct.)
mk_card(ns, colorant::String; kwargs...) =
  mk_card(ns,
          (convert(RGB, parse(Colorant, colorant)), colorant);
          kwargs...)

mk_card(ns, (col, col_name); num=0, round=0, date=nothing, draft=false) = """
  %!PS
  % Bingo card template
  % Written by Tucker R. Twomey
  /in {72 mul} def

  % Hardware margin
  /hwmargin  0.1389 in            def

  % Get paper dimensions
  currentpagedevice /PageSize get
  dup
  /width    exch 0 get def
  /height   exch 1 get def

  /DeviceCMYK setcolorspace
  % C M   Y   K
  0.0 0.0 0.0 1.0 setcolor

  % Function to draw box
  /rect
  {
    % Convert coord pairs to arrays to make stack ops easier
    4 array astore /coord exch def % Shame!
    % Stack is currently [ x2 y2 x1 y1 ] (top)
    % X1 and Y1
    %aload 4 2 roll moveto
    %dup aload pop moveto
    % X1          Y1
    coord 2 get   coord 3 get moveto
    % X1          Y2
    coord 2 get   coord 1 get lineto
    % X2          Y2
    coord 0 get   coord 1 get lineto
    % X2          Y1
    coord 0 get   coord 3 get lineto
    closepath
  } def

  /strike
  {
    % Convert coord pairs to arrays to make stack ops easier
    4 array astore /coord exch def % Shame!
    % Stack is currently [ x2 y2 x1 y1 ] (top)
    % X1 and Y1
    %aload 4 2 roll moveto
    %dup aload pop moveto
    % X1          Y1
    coord 2 get   coord 3 get moveto
    % X2          Y2
    coord 0 get   coord 1 get lineto stroke
    % X1          Y2
    coord 2 get   coord 1 get moveto
    % X2          Y1
    coord 0 get   coord 3 get lineto stroke
  } def

  %%% Grid drawing
  %%  Usage: [ <x1> <y1> <x2> <y2> <box-length> <box-height> ] grid-draw
  /grid
  {
    /args exch def
    %% Vertical lines
    % Start               Inc            End
    args 0 get            args 4 get     args 2 get
    {
      dup
      % Y
      args 1 get moveto
      args 3 get  lineto
      stroke
    } for

    %% Horizontal lines
    % Start               Inc            End
    args 1 get            args 5 get     args 3 get
    {
      dup
      % X
      args 0 get exch moveto
      args 2 get exch lineto
      stroke
    } for
  } def

  /gridaddr
  {
    /args exch def
    args 5 get mul args 1 get add
    exch
    args 4 get mul args 0 get add
    exch
  } def

  /gridx1 1 in def
  /gridy1 height 1 in sub 1.3 in 5.6 mul sub def
  /gridx2 7.5 in def
  /gridy2 height 1 in sub 1.3 in 0.6 mul sub def
  /gridbw 1.3 in def
  /gridbh 1.3 in def
  /ga  { [ gridx1 gridy1 gridx2 gridy2 gridbw gridbh ] gridaddr } def
  /gat { ga 25 add exch 05 add exch } def

  /DeviceRGB setcolorspace
  $(float(col.r)) $(float(col.g)) $(float(col.b)) setcolor

  /URWGothic-Book 20 selectfont
  0 -0.25 ga moveto
  (Supporting) show
  /URWGothic-Demi 45 selectfont
  0 -0.65 ga moveto
  (El Cerrito) show
  0 -1.05 ga moveto
  (Forensics) show

  $(
  if draft
    """
    gsave
    0.8 setgray % Faint gray
    /Helvetica 175 selectfont
    2 2 ga moveto
    58 rotate
    (Draft) show
    grestore
    gsave
    0.0 setgray % Black
    20 setlinewidth
    0 0 ga 2.25 -1.05 ga strike
    grestore
    """
  else
    ""
  end
  )

  %1 in 1 in width 1 in sub height 1 in sub rect stroke

  $(float(col.r)) $(float(col.g)) $(float(col.b)) setcolor
  /Helvetica-Bold 12 selectfont
  3 -0.20 ga moveto
  (Name) show
  %3.50 -0.42 ga 5 -0.33 ga rect stroke
  3.50 -0.20 ga moveto 5 -0.20 ga lineto stroke

  3 -0.31 ga moveto
  (Card) show
  4 -0.31 ga moveto
  ($(@sprintf("%05u", num))) show

  3 -0.42 ga moveto
  (Round) show
  4 -0.42 ga moveto
  ($(@sprintf("%02u (%s)", round, col_name))) show

  $(handle_date(date))

  gridx1 gridy1 gridx2 gridy2 rect stroke
  [ gridx1 gridy1 gridx2 gridy2 gridbw gridbh ] grid

  /URWGothic-Book 46 selectfont
  2 2 ga moveto (Free) show

  /URWGothic-Book 72 selectfont
  0.2 5 ga moveto
  (BINGO)
  [0.5 gridbw add
  -0.3 gridbw add
  -0.1 gridbw add
   0.0 gridbw add
   0.0 gridbw add]
  xshow

  /URWGothic-Book 72 selectfont
  $(mk_grid(ns)...)

  showpage
  """

end
