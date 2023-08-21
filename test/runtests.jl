using TransformsBase
using Test

@testset "TransformsBase.jl" begin
  @test TransformsBase.isrevertible(Identity())
  @test TransformsBase.isinvertible(Identity())
  @test inv(Identity()) == Identity()
  @test inv(Identity() → Identity()) == Identity()
  @test (Identity() → Identity()) == Identity()

  # test fallbacks
  struct TestTransform <: TransformsBase.Transform end
  TransformsBase.apply(::TestTransform, x) = x, nothing
  T = TestTransform()
  @test !TransformsBase.isrevertible(T)
  @test !TransformsBase.isinvertible(T)
  @test TransformsBase.assertions(T) |> isempty
  @test TransformsBase.preprocess(T) |> isnothing
  @test TransformsBase.reapply(T, 1, nothing) == 1
end
