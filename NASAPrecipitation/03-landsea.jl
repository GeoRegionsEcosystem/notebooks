### A Pluto.jl notebook ###
# v0.19.45

using Markdown
using InteractiveUtils

# ╔═╡ dcf31c28-cbb0-4aa9-b371-72e002bfb455
begin
	using Pkg; Pkg.activate()
	using DrWatson
	md"Using DrWatson to ensure package compatability"
end

# ╔═╡ c5ce5d54-21fe-4be3-b5b4-4d68dac1a190
begin
	@quickactivate "GeoRegionsEcosystem"
	using DelimitedFiles
	using NASAPrecipitation
	using NCDatasets
	using PlutoUI

	using CairoMakie
	md"Activating GeoRegionsEcosystem Project for work do be done on notebook ..."
end

# ╔═╡ af53ce52-accb-11ee-2a0c-95b8bf3adea9
md"
# 03. Land-Sea Datasets

This notebooks showcases an extension of the AbstractLandSea Type of GeoRegions.jl by NASAPrecipitation.jl
"

# ╔═╡ b6c4ab4f-ff93-4fd4-b4cd-ede1956ed022
TableOfContents()

# ╔═╡ d3c4f7a6-1222-4484-8fb8-745f6e05f184
begin
	if !isfile(datadir("coast.cst"))
		download(
			"https://raw.githubusercontent.com/natgeo-wong/GeoPlottingData/main/coastline_resl.txt",
			datadir("coast.cst")
		)
	end
	coast = readdlm(datadir("coast.cst"),comments=true)
	clon  = coast[:,1]
	clat  = coast[:,2]
	md"Preloading coastline data"
end

# ╔═╡ 8ad55e37-3667-4ccd-b700-15174346939b
md"
### A. What is a LandSea Dataset?

A LandSea dataset contains information on the topography and the land-sea mask.

The supertype is `AbstractLandSea`, with the following subtypes:
* `LandSeaTopo` for datasets with topographic information
* `LandSeaFlat` for datsets with only the land-sea mask and no topographic info

Why do we need to know the Land-Sea Mask?

Quite often, algorithmic retrieval of atmospheric properties is dependent on whether the surface is land or ocean/water.

GeoRegions.jl exports the `AbstractLandSea`, `LandSeaTopo` and `LandSeaFlat` types, so other packages (e.g., NASAPrecipitation.jl, ERA5Reanalysis.jl) can use it.
"

# ╔═╡ 38279b06-efd5-474d-ae16-5caa5342d190
md"
### B. NASAPrecipitation.jl Land-Sea Masks

NASAPrecipitation.jl fully supports the retrieval of both the TRMM 0.25º and IMERG 0.1º Land-Sea datasets.
"

# ╔═╡ 91980a36-ee56-42d4-a7e4-4e7af283e6b7
npd_imerg = IMERGDummy(path=datadir())

# ╔═╡ 4e2822ff-6947-4dad-8b25-933833adbd81
npd_trmm = TRMMDummy(path=datadir())

# ╔═╡ 7e74fc21-eb8a-4218-8f92-04997217cf2c
geo = RectRegion("BRZ","GLB","Brazil",[15,-35,330,275],save=false)

# ╔═╡ dcb64994-c710-49b8-ad7f-ad87c41d3101
md"
And notice, that similar to GeoRegions.jl, we can use the `getLandSea()` function, in a very similar manner.

This is an example of how we can expand functions using different methods and `Types`. You can check the livedocs for more clarity.
"

# ╔═╡ 58749000-f23f-4f9d-a32f-13f5abaeb908
lsd_imerg = getLandSea(npd_imerg,geo)

# ╔═╡ 9e084968-69a3-4f5c-9a3e-27315da11827
lsd_trmm = getLandSea(npd_trmm,geo)

# ╔═╡ 245ec30b-8b09-4616-a6e5-0c3d6d96ec3e
md"We can see that the NASAPrecipitation LandSea Type is a subtype of the LandSeaFlat superType"

# ╔═╡ 8fc5ebff-e2d5-4828-af7c-25f9e83da002
typeof(lsd_imerg)

# ╔═╡ 14da0c5a-93da-43c6-95b8-e2b45a077b0a
supertype(typeof(lsd_imerg))

# ╔═╡ 19583f27-b37b-473d-a5d4-c6a4d5829c2e
begin
	fig = Figure()

	axsize = 300
	ax1 = Axis(
	    fig[1,1],width=axsize,height=axsize/((geo.E-geo.W)/(geo.N-geo.S)),
	    title="IMERG Land-Sea Mask",xlabel="Longitude / º",ylabel="Latitude / º",
	    limits=(geo.W,geo.E,geo.S,geo.N)
	)
	ax2 = Axis(
	    fig[1,2],width=axsize,height=axsize/((geo.E-geo.W)/(geo.N-geo.S)),
	    title="TRMM Land-Sea Mask",xlabel="Longitude / º",
	    limits=(geo.W,geo.E,geo.S,geo.N)
	)

	contourf!(
	    ax1,lsd_imerg.lon,lsd_imerg.lat,lsd_imerg.lsm,colormap=:delta,
	    levels=range(0.1,0.9,length=9),extendlow=:auto,extendhigh=:auto
	)
	contourf!(
	    ax2,lsd_trmm.lon,lsd_trmm.lat,lsd_trmm.lsm,colormap=:delta,
	    levels=range(0.1,0.9,length=9),extendlow=:auto,extendhigh=:auto
	)
	lines!(ax1,clon,clat,color=:black,linewidth=0.5)
	lines!(ax2,clon,clat,color=:black,linewidth=0.5)
	
	resize_to_layout!(fig)
	fig
end

# ╔═╡ b0dbdafa-74dd-4c85-8aca-989854c44704
md"
### C. Now you try!
"

# ╔═╡ 35d7077f-4bb4-467f-8a1b-8544a5999303
# tst = RectRegion(
# 	"","GLB","",
# 	[],save=false
# )

# ╔═╡ 3a975d77-3494-4d99-8472-b6914143ccca
lsd_tst = getLandSea(tst,savelsd=false)

# ╔═╡ de4a1d2c-752e-4e36-84e6-c1e21b1acb7d
begin
	fig2 = Figure()

	ax2_1 = Axis(
	    fig2[1,1],width=axsize,height=axsize/((geo.E-geo.W)/(geo.N-geo.S)),
	    title="Tropography",
		xlabel="Longitude / º",ylabel="Latitude / º",
	    limits=(geo.W,geo.E,geo.S,geo.N)
	)
	ax2_2 = Axis(
	    fig2[1,2],width=axsize,height=axsize/((geo.E-geo.W)/(geo.N-geo.S)),
	    title="Land-Sea Mask",
		xlabel="Longitude / º",ylabel="Latitude / º",
	    limits=(geo.W,geo.E,geo.S,geo.N)
	)

	contourf!(
	    ax2_1,lsd_tst.lon,lsd_tst.lat,lsd_tst.z/1000,colormap=:delta,
	    levels=range(-0.5,0.5,length=51),extendlow=:auto,extendhigh=:auto
	)
	contourf!(
	    ax2_2,lsd_tst.lon,lsd_tst.lat,lsd_tst.lsm,colormap=:delta,
	    levels=range(0,1,length=2),extendlow=:auto,extendhigh=:auto
	)
	lines!(ax2_1,clon,clat,color=:black,linewidth=0.5)
	lines!(ax2_2,clon,clat,color=:black,linewidth=0.5)
	
	resize_to_layout!(fig2)
	fig2
end

# ╔═╡ cce20789-82f0-4bd3-b818-9142f1400414
# ╠═╡ disabled = true
#=╠═╡
npd = IMERGDummy(path=datadir())
  ╠═╡ =#

# ╔═╡ Cell order:
# ╟─af53ce52-accb-11ee-2a0c-95b8bf3adea9
# ╟─dcf31c28-cbb0-4aa9-b371-72e002bfb455
# ╟─c5ce5d54-21fe-4be3-b5b4-4d68dac1a190
# ╟─b6c4ab4f-ff93-4fd4-b4cd-ede1956ed022
# ╟─d3c4f7a6-1222-4484-8fb8-745f6e05f184
# ╟─8ad55e37-3667-4ccd-b700-15174346939b
# ╟─38279b06-efd5-474d-ae16-5caa5342d190
# ╠═91980a36-ee56-42d4-a7e4-4e7af283e6b7
# ╠═4e2822ff-6947-4dad-8b25-933833adbd81
# ╠═7e74fc21-eb8a-4218-8f92-04997217cf2c
# ╟─dcb64994-c710-49b8-ad7f-ad87c41d3101
# ╠═58749000-f23f-4f9d-a32f-13f5abaeb908
# ╠═9e084968-69a3-4f5c-9a3e-27315da11827
# ╟─245ec30b-8b09-4616-a6e5-0c3d6d96ec3e
# ╠═8fc5ebff-e2d5-4828-af7c-25f9e83da002
# ╠═14da0c5a-93da-43c6-95b8-e2b45a077b0a
# ╟─19583f27-b37b-473d-a5d4-c6a4d5829c2e
# ╟─b0dbdafa-74dd-4c85-8aca-989854c44704
# ╠═35d7077f-4bb4-467f-8a1b-8544a5999303
# ╠═3a975d77-3494-4d99-8472-b6914143ccca
# ╠═de4a1d2c-752e-4e36-84e6-c1e21b1acb7d
# ╟─cce20789-82f0-4bd3-b818-9142f1400414
