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

  # sequential
  T = TransformsBase.SequentialTransform([TestTransform(), Identity()])

  # equality
  @test T == T

  # iteration interface
  @test length(T) == 2
  T1, state = iterate(T)
  @test T1 == TestTransform()
  T2, state = iterate(T, state)
  @test T2 == Identity()
  @test isnothing(iterate(T, state))
  # indexing interface
  @test T[1] == TestTransform()
  @test T[2] == Identity()
  @test firstindex(T) == 1
  @test lastindex(T) == 2
  @test T[begin] == TestTransform()
  @test T[end] == Identity()

  # equality and approximation
  struct TestParamTransform <: TransformsBase.Transform
    param::Float64
  end
  TransformsBase.apply(t::TestParamTransform, x) = x * t.param, nothing
  TransformsBase.parameters(t::TestParamTransform) = (; param=t.param)
  T1 = TestParamTransform(1.0)
  T2 = TestParamTransform(1.0f0)
  T3 = TestTransform()
  @test T1 == T2
  @test T1 ≠ T3
  @test T1 ≈ T2
  @test T1 ≉ T3

  T1 = Identity()
  T2 = TestTransform()
  T3 = TestTransform() → TestTransform()
  @test sprint(show, T1) == "Identity()"
  @test sprint(show, MIME("text/plain"), T1) == "Identity transform"
  @test sprint(show, T2) == "TestTransform()"
  @test sprint(show, MIME("text/plain"), T2) == "TestTransform transform"
  @test sprint(show, T3) == "TestTransform() → TestTransform()"
  @test sprint(show, MIME("text/plain"), T3) == """
  SequentialTransform
  ├─ TestTransform()
  └─ TestTransform()"""
end
