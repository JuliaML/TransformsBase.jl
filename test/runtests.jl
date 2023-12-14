using TransformsBase
using Test

@testset "TransformsBase.jl" begin
  @test TransformsBase.isrevertible(Identity())
  @test TransformsBase.isinvertible(Identity())
  @test TransformsBase.inverse(Identity()) == Identity()
  @test TransformsBase.inverse(Identity() → Identity()) == Identity()
  @test (Identity() → Identity()) == Identity()

  # test fallbacks
  struct TestTransform <: TransformsBase.Transform end
  TransformsBase.apply(::TestTransform, x) = x, nothing
  T = TestTransform()
  @test !TransformsBase.isrevertible(T)
  @test !TransformsBase.isinvertible(T)
  @test !TransformsBase.isrevertible(T → T)
  @test !TransformsBase.isinvertible(T → T)
  @test TransformsBase.assertions(T) |> isempty
  @test TransformsBase.parameters(T) isa NamedTuple
  @test TransformsBase.parameters(T) |> isempty
  @test TransformsBase.preprocess(T, nothing) |> isnothing
  @test TransformsBase.reapply(T, 1, nothing) == 1

  # test optimizations
  T = TestTransform() → TestTransform()
  @test (T → Identity()) == T
  @test (Identity() → T) == T
end
