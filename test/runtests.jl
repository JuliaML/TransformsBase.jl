using TransformsBase
using Test

@testset "TransformsBase.jl" begin
  @test TransformsBase.isrevertible(Identity())
  @test TransformsBase.isinvertible(Identity())
  @test inv(Identity()) == Identity()
  @test (Identity() → Identity()) == Identity()
end
