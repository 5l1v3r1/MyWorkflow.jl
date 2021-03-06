# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .jl
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.5.0
#   kernelspec:
#     display_name: Julia 1.4.2
#     language: julia
#     name: julia-1.4
# ---

using Plots
using Distributions
using LinearAlgebra
using ForwardDiff

# +
struct Point{T<:Real}
    x::T
    y::T
    z::T
end


Point(xyz::Vector{T}) where {T} = Point{T}(T.(xyz)...)

# +
struct Tp
    zfunc::Function
    gx::Float64
    gy::Float64
    p::Point{Float64}
end

function Tp(zfunc, p_xy)
    zfuncwrap(xy) = zfunc(xy...)
    g = xy -> ForwardDiff.gradient(zfuncwrap, xy)
    ∇g_x, ∇g_y = g(p_xy)
    Tp(zfunc, ∇g_x, ∇g_y, Point([p_xy..., zfuncwrap(p_xy)]))
end

function tangent_plane(tp::Tp, x, y)
    z = tp.gx * (x-tp.p.x) + tp.gy * (y-tp.p.y)+ tp.p.z
    return z
end
# -

zfunc(x, y) = -x^2-y^2+1.
tp = Tp(zfunc, [3.0, 1.0])

function visualize(tp::Tp; camera = (0, 30))
    tp_offset=0.5
    offset=1.0
    tp_xs = range(tp.p.x - tp_offset, tp.p.x + tp_offset, length = 10)
    tp_ys = range(tp.p.y - tp_offset, tp.p.y + tp_offset, length = 10)
    xs = range(tp.p.x - offset, tp.p.x + offset, length = 20)
    ys = range(tp.p.y - offset, tp.p.y + offset, length = 20)
    p = plot(xlabel="x", ylabel="y")
    wireframe!(p, xs, ys, (x, y) -> tp.zfunc(x, y), camera = camera)
    surface!(p, tp_xs, tp_ys, (x, y) -> tangent_plane(tp, x, y), camera = camera)
    scatter3d!(p, [tp.p.x],[tp.p.y],[tp.p.z], label="p")
    return p
end

ps=[]
for θ in 1:90
    IJulia.clear_output(true)
    p = visualize(tp, camera = (θ, 30))
    p |> display
    push!(ps, p)
end

@gif for p in ps
    plot(p)
end
