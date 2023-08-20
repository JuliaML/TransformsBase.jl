using TransformsBase
using Test

@testset "TransformsBase.jl" begin
  @test TransformsBase.isrevertible(Identity())
  @test TransformsBase.isinvertible(Identity())
  @test inv(Identity()) == Identity()
  @test inv(Identity() → Identity()) == Identity()
  @test (Identity() → Identity()) == Identity()

  # Testing Fallbacks
  struct TestTransform <: Transform end
  T = TestTransform()

  @testset "reapply" begin
    TransformsBase.apply(::TestTransform, x) = x
    @test TransformsBase.reapply(T, 1, nothing) == TransformsBase.apply(T, 1) |> first
    TransformsBase.reapply(::TestTransform, x, cache) = 2 * x
    @test TransformsBase.reapply(T, 1, nothing) == 2
    @test TransformsBase.reapply(T, 1, nothing) != TransformsBase.apply(T, 1) |> first
  end

  @testset "revert" begin
    @test_throws "Can't revert the non-revertible transform TestTransform()" begin
      TransformsBase.revert(T, 1, nothing)
    end
    @test_throws "Transform TestTransform() is revertible but revert is not yet implemented" begin
      TransformsBase.isrevertible(::TestTransform) = true
      TransformsBase.revert(T, 1, nothing)
    end
    TransformsBase.revert(::TestTransform, x, cache) = x
    x2 = TransformsBase.revert(T, 1, nothing)
    @test x2 == 1
  end

  @testset "isinvertible" begin
    @test !TransformsBase.isinvertible(T)
    @test_throws "Can't invert the non-invertible transform TestTransform()" begin
      Base.inv(T)
    end
    @test_throws "Transform TestTransform() is invertible but inv is not yet implemented" begin
      TransformsBase.isinvertible(::TestTransform) = true
      Base.inv(T)
    end
    Base.inv(::TestTransform) = TestTransform()
    @test Base.inv(T) == T
  end
end
