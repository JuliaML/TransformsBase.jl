# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    SequentialTransform(transforms)

A transform where `transforms` are applied in sequence.
"""
struct SequentialTransform <: Transform
  transforms::Vector{Transform}
end

isrevertible(s::SequentialTransform) = all(isrevertible, s.transforms)

isinvertible(s::SequentialTransform) = all(isinvertible, s.transforms)

Base.inv(s::SequentialTransform) = SequentialTransform([inv(t) for t in reverse(s.transforms)])

function apply(s::SequentialTransform, table)
  allcache = []
  current  = table
  for transform in s.transforms
    current, cache = apply(transform, current)
    push!(allcache, cache)
  end
  current, allcache
end

function revert(s::SequentialTransform, newtable, cache)
  allcache = deepcopy(cache)
  current  = newtable
  for transform in reverse(s.transforms)
    current = revert(transform, current, pop!(allcache))
  end
  current
end

function reapply(s::SequentialTransform, table, cache)
  # basic checks
  ntrans = length(s.transforms)
  ncache = length(cache)

  if ntrans != ncache
    throw(ErrorException("invalid cache for transform"))
  end

  current = table
  for (ctransform, ccache) in zip(s.transforms, cache)
    current = reapply(ctransform, current, ccache)
  end

  current
end

"""
    transform₁ → transform₂ → ⋯ → transformₙ

Create a [`SequentialTransform`](@ref) transform with
`[transform₁, transform₂, …, transformₙ]`.
"""
→(t1::Transform, t2::Transform) =
  SequentialTransform([t1, t2])
→(t1::Transform, t2::SequentialTransform) =
  SequentialTransform([t1; t2.transforms])
→(t1::SequentialTransform, t2::Transform) =
  SequentialTransform([t1.transforms; t2])
→(t1::SequentialTransform, t2::SequentialTransform) =
  SequentialTransform([t1.transforms; t2.transforms])

# AbstractTrees interface
AbstractTrees.nodevalue(::SequentialTransform) = SequentialTransform
AbstractTrees.children(s::SequentialTransform) = s.transforms

Base.show(io::IO, s::SequentialTransform) =
  print(io, join(s.transforms, " → "))

function Base.show(io::IO, ::MIME"text/plain", s::SequentialTransform)
  tree = AbstractTrees.repr_tree(s, context=io)
  print(io, tree[begin:end-1]) # remove \n at end
end
