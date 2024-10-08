# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Transform

A transform that takes an object as input and produces a new object.
Any transform implementing the `Transform` trait should implement the
[`apply`](@ref) function. If the transform [`isrevertible`](@ref),
then it should also implement the [`revert`](@ref) function.

A functor interface is automatically generated from the functions
above, which means that any transform implementing the `Transform`
trait can be evaluated directly at any object.
"""
abstract type Transform end

"""
    isrevertible(transform)

Tells whether or not the `transform` is revertible, i.e. supports a
[`revert`](@ref) function. Defaults to `false` for new transform types.

Transforms can be revertible and yet don't be invertible. Invertibility
is a mathematical concept, whereas revertibility is a computational concept.

See also [`isinvertible`](@ref).
"""
function isrevertible end

"""
    isinvertible(transform)

Tells whether or not the `transform` is invertible, i.e. whether it
implements the `inverse` function. Defaults to `false` for new transform
types.

Transforms can be invertible in the mathematical sense, i.e., there
exists a one-to-one mapping between input and output spaces.

See also [`inverse`](@ref), [`isrevertible`](@ref).
"""
function isinvertible end

"""
    inverse(transform)

Returns the inverse transform of the `transform`.

See also [`isinvertible`](@ref).
"""
function inverse end

"""
    assertions(transform)

Returns a list of assertion functions for the `transform`. An assertion
function is a function that takes an object as input and checks if the
object is valid for the `transform`.
"""
function assertions end

"""
    parameters(transform)

Returns a named tuple with the adjustable parameters of the `transform`.
"""
function parameters end

"""
    prep = preprocess(transform, object)

Pre-process `object` with `transform` to produce a `preproc` object.
This function is intended for developers of new transform types.
"""
function preprocess end

"""
    newobject, cache = apply(transform, object)

Apply `transform` on the `object`. Return the `newobject`
and a `cache` to revert the transform later.
"""
function apply end

"""
    object = revert(transform, newobject, cache)

Revert the `transform` on the `newobject` using the `cache`
from the corresponding [`apply`](@ref) call and return the
original `object`. Only defined when the `transform`
[`isrevertible`](@ref).
"""
function revert end

"""
    newobject = reapply(transform, object, cache)

Reapply the `transform` to (a possibly different) `object`
using a `cache` that was created with a previous [`apply`](@ref)
call. Fallback to [`apply`](@ref) without using the `cache`.
"""
function reapply end

# --------------------
# TRANSFORM FALLBACKS
# --------------------

isrevertible(transform::Transform) = isrevertible(typeof(transform))
isrevertible(::Type{<:Transform}) = false

isinvertible(transform::Transform) = isinvertible(typeof(transform))
isinvertible(::Type{<:Transform}) = false

assertions(transform::Transform) = []

parameters(transform::Transform) = (;)

preprocess(transform::Transform, object) = nothing

reapply(transform::Transform, object, cache) = apply(transform, object) |> first

(transform::Transform)(object) = apply(transform, object) |> first

Base.:(==)(t₁::Transform, t₂::Transform) = nameof(typeof(t₁)) == nameof(typeof(t₂)) && parameters(t₁) == parameters(t₂)

Base.isapprox(t₁::Transform, t₂::Transform; kwargs...) =
  nameof(typeof(t₁)) == nameof(typeof(t₂)) && _isapprox(parameters(t₁), parameters(t₂); kwargs...)

_isapprox(tup₁::NamedTuple, tup₂::NamedTuple; kwargs...) =
  propertynames(tup₁) == propertynames(tup₂) && _isapprox(Tuple(tup₁), Tuple(tup₂); kwargs...)

_isapprox(tup₁::Tuple, tup₂::Tuple; kwargs...) =
  length(tup₁) == length(tup₂) && all(_isapprox(x₁, x₂; kwargs...) for (x₁, x₂) in zip(tup₁, tup₂))

_isapprox(x₁, x₂; kwargs...) = isapprox(x₁, x₂; kwargs...)

# -----------
# IO METHODS
# -----------

Base.summary(io::IO, transform::Transform) = print(io, "$(prettyname(transform)) transform")

function Base.show(io::IO, transform::Transform)
  name = prettyname(transform)
  ioctx = IOContext(io, :compact => true)
  print(io, "$name(")
  printfields(ioctx, transform, singleline=true)
  print(io, ")")
end

function Base.show(io::IO, ::MIME"text/plain", transform::Transform)
  summary(io, transform)
  printfields(io, transform)
end
