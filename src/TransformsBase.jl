# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

module TransformsBase

import AbstractTrees

include("interface.jl")
include("sequential.jl")
include("identity.jl")

export
  Transform,
  Identity,
  →

end
