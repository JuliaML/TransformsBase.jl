# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Identity()

The identity transform that maps any object to itself.
"""
struct Identity <: Transform end

isrevertible(::Type{Identity}) = true

isinvertible(::Type{Identity}) = true

inverse(::Identity) = Identity()

apply(::Identity, object) = object, nothing

revert(::Identity, newobject, cache) = newobject

reapply(::Identity, object, cache) = object

# --------------
# OPTIMIZATIONS
# --------------

→(t::Transform, ::Identity) = t
→(::Identity, t::Transform) = t
→(t::SequentialTransform, ::Identity) = t
→(::Identity, t::SequentialTransform) = t
→(::Identity, ::Identity) = Identity()