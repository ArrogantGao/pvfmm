using Test
using PVFMM

@testset "PVFMM Julia interface parity" begin
    @test isdefined(PVFMM, :FMMKernel)
    @test isdefined(PVFMM, :FMMVolumeContext)
    @test isdefined(PVFMM, :FMMParticleContext)
    @test isdefined(PVFMM, :FMMVolumeTree)
    @test isdefined(PVFMM, :nodes_to_coeff)

    expected_exports = (
        :FMMKernel,
        :FMMVolumeContext,
        :FMMParticleContext,
        :FMMVolumeTree,
        :nodes_to_coeff,
    )
    for name in expected_exports
        @test name in names(PVFMM)
    end
end

@testset "Revise conflict guard" begin
    revise_path = Base.find_package("Revise")
    if revise_path === nothing
        @test_skip "Revise is not installed in this environment"
    else
        expr = """
        using Revise
        using PVFMM
        try
            PVFMM.FMMParticleContext(0.0, 50, 8, PVFMM.LaplacePotential)
            println("unexpected success")
            exit(2)
        catch err
            msg = sprint(showerror, err)
            if occursin("incompatible with Revise", msg)
                println("guarded")
                exit(0)
            end
            println(msg)
            exit(3)
        end
        """
        cmd = `$(Base.julia_cmd()) --startup-file=no --project=$(Base.active_project()) -e $expr`
        @test success(cmd)
    end
end

include("reference_comparison.jl")
