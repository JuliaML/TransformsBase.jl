using TransformsBase
using Test

@testset "TransformsBase.jl" begin
  @test (Identity() → Identity()) == Identity()
end
