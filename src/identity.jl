# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Identity()

The identity transform that maps any object to itself.
"""
struct Identity <: Transform end

isrevertible(::Type{Identity}) = true

apply(::Identity, object) = object, nothing

revert(::Identity, newobject, cache) = newobject

reapply(::Identity, object, cache) = object