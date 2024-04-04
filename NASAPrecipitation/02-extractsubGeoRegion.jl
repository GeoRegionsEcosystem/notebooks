### A Pluto.jl notebook ###
# v0.19.40

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

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
# 02. Extracting Data!
"

# ╔═╡ b6c4ab4f-ff93-4fd4-b4cd-ede1956ed022
TableOfContents()

# ╔═╡ f07f1d25-80f9-4017-a4ab-09b1a52db3ee
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

# ╔═╡ ec4ae8bf-cfbd-430f-8242-6d129bd963db
md"
### A. Loading Datasets and Predefining GeoRegions
"

# ╔═╡ 2215440a-5cf1-47b9-aa4b-775f10b7c6cc
npd = IMERGMonthly(start=Date(2017),stop=Date(2017),path=datadir())

# ╔═╡ b4a60181-384f-467d-9bec-17122296da5d
geo_SMT = RectRegion("SMT","GLB","Sumatra",[6,-6,107,95],savegeo=false)

# ╔═╡ 8493f2b7-154a-42b2-a02a-919a98409706
geo_SGP = RectRegion("SGP","GLB","Singapore",[2,1,104.5,103],savegeo=false)

# ╔═╡ 06327987-2728-463d-bd25-b231ef276dda
begin
	slon_SMT,slat_SMT = coordGeoRegion(geo_SMT);
	slon_SGP,slat_SGP = coordGeoRegion(geo_SGP);
	md"Loading coordinates"
end

# ╔═╡ 2576c5d1-1630-4838-a57f-7f58023b2434
begin
	fig = Figure()
	aspect = 1
	
	ax1 = Axis(
	    fig[1,1],width=300,height=300/aspect,
	    title="Sumatra",
		xlabel="Longitude / º",ylabel="Latitude / º",
	    limits=(geo_SMT.W-1,geo_SMT.E+1,geo_SMT.S-1,geo_SMT.N+1)
	)
	ax2 = Axis(
	    fig[1,2],width=300,height=300/aspect,
	    title="Singapore",
		xlabel="Longitude / º",ylabel="Latitude / º",
	    limits=(geo_SMT.W-1,geo_SMT.E+1,geo_SMT.S-1,geo_SMT.N+1)
	)
	lines!(ax1,clon,clat,color=:black,linewidth=0.5)
	lines!(ax2,clon,clat,color=:black,linewidth=0.5)
	lines!(ax1,slon_SMT,slat_SMT,color=:blue,linewidth=2)
	lines!(ax2,slon_SGP,slat_SGP,color=:blue,linewidth=2)

	Colorbar(fig[1, 3], limits = (0, 20), colormap = cgrad(:viridis, 20, categorical = true), size = 31)
	
	resize_to_layout!(fig)
	fig
end

# ╔═╡ 20a958f9-627a-4399-a1d9-5e10533b3059
md"
### B. Extracting Data for the SGP Region from the SMT Region

Building upon the functionalities of GeoRegions.jl, all you need to do to extract data for a given region from a larger region, is the function `extract(npd,sgeo,pgeo)`, where:
* `npd` is the dataset that defines both the time-range and data path
* `sgeo` is the smaller GeoRegion
* `pgeo` is the parent (larger) GeoRegion
"

# ╔═╡ 423c5a8a-e7b4-416a-b586-1eaadcbcd1ee
extract(npd,geo_SGP,geo_SMT)

# ╔═╡ ac3994b7-4b1b-452b-8a8d-0aaee51fcf91
begin
	ds = read(npd,geo_SMT,Date(2017))
	lon_SMT  = ds["longitude"][:]
	lat_SMT  = ds["latitude"][:]
	prcp_SMT = ds["precipitation"][:,:,:] * 86400
	close(ds)
	ds = read(npd,geo_SGP,Date(2017))
	lon_SGP  = ds["longitude"][:]
	lat_SGP  = ds["latitude"][:]
	prcp_SGP = ds["precipitation"][:,:,:] * 86400
	close(ds)
	md"Loading data from NetCDF file ..."
end

# ╔═╡ 7c152fc5-5cb8-484e-b30e-2c1b7e62e462
md"Month: $(@bind imo PlutoUI.Slider(1:12,show_value=true))"

# ╔═╡ d893e4c0-caab-468a-8efc-a743ee2458f7
begin
	ax1.title = "Sumatra Monthly GPM Precipitation | 2017-$imo"
	ax2.title = "Singapore Monthly GPM Precipitation | 2017-$imo"
	contourf!(
		ax1,lon_SMT,lat_SMT,prcp_SMT[:,:,imo],
		levels=range(0,20,length=11),extendhigh=:auto
	)
	contourf!(
		ax2,lon_SGP,lat_SGP,prcp_SGP[:,:,imo],
		levels=range(0,20,length=11),extendhigh=:auto
	)
	lines!(ax1,clon,clat,color=:black,linewidth=0.5)
	lines!(ax2,clon,clat,color=:black,linewidth=0.5)
	fig
end

# ╔═╡ Cell order:
# ╟─af53ce52-accb-11ee-2a0c-95b8bf3adea9
# ╠═dcf31c28-cbb0-4aa9-b371-72e002bfb455
# ╟─c5ce5d54-21fe-4be3-b5b4-4d68dac1a190
# ╟─b6c4ab4f-ff93-4fd4-b4cd-ede1956ed022
# ╟─f07f1d25-80f9-4017-a4ab-09b1a52db3ee
# ╟─ec4ae8bf-cfbd-430f-8242-6d129bd963db
# ╠═2215440a-5cf1-47b9-aa4b-775f10b7c6cc
# ╠═b4a60181-384f-467d-9bec-17122296da5d
# ╠═8493f2b7-154a-42b2-a02a-919a98409706
# ╟─06327987-2728-463d-bd25-b231ef276dda
# ╟─2576c5d1-1630-4838-a57f-7f58023b2434
# ╟─20a958f9-627a-4399-a1d9-5e10533b3059
# ╠═423c5a8a-e7b4-416a-b586-1eaadcbcd1ee
# ╟─ac3994b7-4b1b-452b-8a8d-0aaee51fcf91
# ╟─7c152fc5-5cb8-484e-b30e-2c1b7e62e462
# ╟─d893e4c0-caab-468a-8efc-a743ee2458f7
