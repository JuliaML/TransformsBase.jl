using TransformsBase
using Test

@testset "TransformsBase.jl" begin
  @test TransformsBase.isrevertible(Identity())
  @test TransformsBase.isinvertible(Identity())
  @test inv(Identity()) == Identity()
  @test inv(Identity() → Identity()) == Identity()
  @test (Identity() → Identity()) == Identity()
end

@testset "Testing Fallbacks" begin
  struct TestTransform <: TransformsBase.Transform end
  T = TestTransform()

  @testset "reapply" begin
    TransformsBase.apply(::TestTransform, x) = x, nothing
    @test TransformsBase.reapply(T, 1, nothing) == TransformsBase.apply(T, 1) |> first
    TransformsBase.reapply(::TestTransform, x, cache) = 2 * x
    @test TransformsBase.reapply(T, 1, nothing) == 2
    @test TransformsBase.reapply(T, 1, nothing) != TransformsBase.apply(T, 1) |> first
  end

  @testset "revert" begin
    @test_throws "Can't revert the non-revertible transform TestTransform()" begin
      TransformsBase.revert(T, 1, nothing)
    end
    TransformsBase.isrevertible(::TestTransform) = true
    TransformsBase.revert(::TestTransform, x, cache) = x
    x2 = TransformsBase.revert(T, 1, nothing)
    @test x2 == 1
  end

  @testset "isinvertible" begin
    @test !TransformsBase.isinvertible(T)
    @test_throws "Can't invert the non-invertible transform TestTransform()" begin
      Base.inv(T)
    end
    TransformsBase.isinvertible(::TestTransform) = true
    Base.inv(::TestTransform) = TestTransform()
    @test Base.inv(T) == T
  end
end
