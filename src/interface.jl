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
    assertions(transform)

Returns a list of assertion functions for the `transform`. An assertion
function is a function that takes an object as input and checks if the
object is valid for the `transform`.
"""
function assertions end

"""
    isrevertible(transform)

Tells whether or not the `transform` is revertible, i.e. supports a
[`revert`](@ref) function. Defaults to `false` for new transform types.
"""
function isrevertible end

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

Reapply the `transform` to (a possibly different) `object` using a `cache`
that was created with a previous [`apply`](@ref) call.
"""
function reapply end

# --------------------
# TRANSFORM FALLBACKS
# --------------------

assertions(transform::Transform) =
  assertions(typeof(transform))
assertions(::Type{<:Transform}) = []

isrevertible(transform::Transform) =
  isrevertible(typeof(transform))
isrevertible(::Type{<:Transform}) = false

preprocess(transform::Transform, object) = nothing

(transform::Transform)(object) =
  apply(transform, object) |> first

function Base.show(io::IO, transform::Transform)
  T = typeof(transform)
  vals = getfield.(Ref(transform), fieldnames(T))
  strs = repr.(vals, context=io)
  print(io, "$(nameof(T))($(join(strs, ", ")))")
end

function Base.show(io::IO, ::MIME"text/plain", transform::Transform)
  T = typeof(transform)
  fnames = fieldnames(T)
  len = length(fnames)
  print(io, "$(nameof(T)) transform")
  for (i, field) in enumerate(fnames)
    div = i == len ? "\n└─ " : "\n├─ "
    val = getfield(transform, field)
    str = repr(val, context=io)
    print(io, "$div$field = $str")
  end
end
