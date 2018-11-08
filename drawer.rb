# LaTeX-preambule (begin and end of document and sets for drawing of shipments):
def tex_preambule_begin
  "\\documentclass[tikz,border=5]{standalone}
  \\usepackage{xxcolor}
  \\usetikzlibrary{arrows.meta}
  \\tikzset{pics/cube/.style args={#1 #2 #3 #4}{code={%
    \\path [#4, fill, draw]
      (0,#2,0)  coordinate (-top-a) -- (#1,#2,0) coordinate (-top-b) --
      (#1,#2,#3) coordinate (-top-c) -- (0,#2,#3) coordinate (-top-d) -- cycle;
    \\path [#4!75!black, fill, draw]
      (#1,0,0) -- (#1,#2,0) -- (#1,#2,#3) -- (#1,0,#3) -- cycle;
    \\path [#4!50!black, fill, draw]
      (0,0,#3) -- (0,#2,#3) -- (#1,#2,#3) -- (#1,0,#3) -- cycle;
  }}}
\\begin{document}"
end
def tex_preambule_end
  "\\end{document}"
end

# Tikz-preambule (begin and end of tikzpicture):
def tikz_begin(aircraft_object)
  x    = aircraft_object.width
  y    = aircraft_object.depth
  z    = aircraft_object.height

"\\begin{tikzpicture}[line join=round, line cap=round,>=Triangle,
   axis/.style={ultra thick, ->, draw=black}]
  \\draw [axis] (0,0,0) -- (#{x + 10},0,0) node (xaxis) [above] {$x$};
  \\draw [axis] (0,0,0) -- (0,#{z + 1},0) node (xaxis) [above] {$z$};
  \\draw [axis] (0,0,0) -- (0,0,#{y + 1}) node (xaxis) [above] {$y$};
  \\begin{colormixin}{85!white}"
end
def tikz_end(name)
  "\\end{colormixin}
  \\node[above,font=\\large\\bfseries] at (current bounding box.north) {aircraft: #{name}};
  \\end{tikzpicture}"
end

# tikz-string generator:
def draw_shipment(shipment)
  # colors for fill of shipment on tikz:
  colors = ["gray",    "gray!50!red",    "gray!50!blue",
            "yellow",  "yellow!50!red",  "yellow!50!blue",
            "black",   "black!50!red",   "black!50!blue",
            "red",     "green!50!red",   "red!50!blue",
            "blue",    "blue!50!red",    "green!50!blue",
            "magenta", "magenta!50!red", "magenta!50!blue",
            "white",   "white!50!red",   "white!50!blue",
            "green",   "green!50!red",   "green!50!blue",
            "cyan",    "cyan!50!red",    "cyan!50!blue",
            "yellow",  "yellow!50!red",  "yellow!50!blue"]

  # coordinates for tikz-shape:
  x1 = shipment.p.x
  y1 = shipment.p.y
  z1 = shipment.p.z
  x2 = shipment.width
  y2 = shipment.depth
  z2 = shipment.height

  # tikz-string
  draw_string = "\\pic at (#{x1},#{z1},#{y1}) {cube={#{x2} #{z2} #{y2} #{colors[rand(colors.size)]}}};\n"

  return draw_string
end
