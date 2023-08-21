using TransformsBase
using Test

@testset "TransformsBase.jl" begin
  @test TransformsBase.isrevertible(Identity())
  @test TransformsBase.isinvertible(Identity())
  @test inv(Identity()) == Identity()
  @test inv(Identity() → Identity()) == Identity()
  @test (Identity() → Identity()) == Identity()

  # testing fallbacks
  struct TestTransform <: TransformsBase.Transform end
  T = TestTransform()

  # test reapply
  TransformsBase.apply(::TestTransform, x) = x, nothing
  @test TransformsBase.reapply(T, 1, nothing) == 1
  TransformsBase.reapply(::TestTransform, x, cache) = 2 * x
  @test TransformsBase.reapply(T, 1, nothing) == 2

  # test revert
  @test !TransformsBase.isrevertible(T)
  @test_throws ErrorException("Can't revert the non-revertible transform TestTransform()") begin
    TransformsBase.revert(T, 1, nothing)
  end
  @test_throws ErrorException("Transform TestTransform() is revertible but revert is not yet implemented") begin
    TransformsBase.isrevertible(::TestTransform) = true
    TransformsBase.revert(T, 1, nothing)
  end
  TransformsBase.revert(::TestTransform, x, cache) = x
  @test TransformsBase.revert(T, 1, nothing) == 1

  # test inv
  @test !TransformsBase.isinvertible(T)
  @test_throws ErrorException("Can't invert the non-invertible transform TestTransform()") begin
    Base.inv(T)
  end
  @test_throws ErrorException("Transform TestTransform() is invertible but inv is not yet implemented") begin
    TransformsBase.isinvertible(::TestTransform) = true
    Base.inv(T)
  end
  Base.inv(::TestTransform) = TestTransform()
  @test Base.inv(T) == T
end
