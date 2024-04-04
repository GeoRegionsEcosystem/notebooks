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
# 01. Introducing NASAPrecipitation.jl
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

# ╔═╡ 8ad55e37-3667-4ccd-b700-15174346939b
md"
### A. Components of NASAPrecipitation.jl

There are two major components necessary in most NASAPrecipitation.jl functions:
* NASAPrecipitation Dataset
* GeoRegion
"

# ╔═╡ e9f4f15e-b23e-4d68-a1eb-ad95730135e4
md"
#### i. Available NASAPrecipitation.jl Datasets

For IMERG:

|           |       `Type`      |    Early NRT     |    Late NRT     |    Final NRT     |
| :-------: | :---------------: | :--------------: | :-------------: | :--------------: |
|  30 Mins  | `IMERGHalfHourly` | `IMERGEarlyHH()` | `IMERGLateHH()` | `IMERGFinalHH()` |
|   Daily   |    `IMERGDaily`   | `IMERGEarlyDY()` | `IMERGLateDY()` | `IMERGFinalDY()` |
|  Monthly  |   `IMERGMonthly`  |                  |                 | `IMERGMonthly()` |

For TRMM:

|          |    `Type`     |   Near Real-Time   |      Final      |
| :------: | :-----------: | :----------------: | :-------------: |
|  3 Hour  | `TRMM3Hourly` | `TRMM3HourlyNRT()` | `TRMM3Hourly()` |
|   Daily  |  `TRMMDaily`  |  `TRMMDailyNRT()`  |  `TRMMDaily()`  |
|  Monthly | `TRMMMonthly` |                    | `TRMMMonthly()` |
"

# ╔═╡ 9d2ecde3-c7f7-4852-972f-18300294a2b0
md"Let us define an IMERGMonthly() Dataset ..."

# ╔═╡ b47c46f7-5dfd-4fea-b47d-a51a3f990ca0
npd = IMERGMonthly(start=Date(2017),stop=Date(2017),path=datadir())

# ╔═╡ d7b1b192-78d6-4f03-b8f7-273cebea1741
md"
#### ii. Now to Define a GeoRegion
"

# ╔═╡ 22ea1049-31b9-4627-8f91-d68d2714fe74
geo = RectRegion("SMT","GLB","Sumatra",[6,-6,107,95],savegeo=false)

# ╔═╡ 9eee56b4-1e3c-427c-aa0c-9e729e709b81
md"Note: `savegeo = false` because we don't want to save this GeoRegion as a custom GeoRegion"

# ╔═╡ 8963c087-d6ec-4488-afc4-6a128d83f2c6
slon,slat = coordGeoRegion(geo);

# ╔═╡ 047ef605-7572-4a36-95c7-4861a06946ad
begin
	fig = Figure()
	aspect = 1
	
	ax1 = Axis(
	    fig[1,1],width=400,height=400/aspect,
	    title="Sumatra",
		xlabel="Longitude / º",ylabel="Latitude / º",
	    limits=(geo.W-1,geo.E+1,geo.S-1,geo.N+1)
	)
	lines!(ax1,clon,clat,color=:black,linewidth=0.5)
	lines!(ax1,slon,slat,color=:blue,linewidth=2)

	Colorbar(fig[1, 2], limits = (0, 20), colormap = cgrad(:viridis, 20, categorical = true), size = 31)
	
	resize_to_layout!(fig)
	fig
end

# ╔═╡ bf009093-b9b7-4137-9f45-c36d04ce2360
md"
### B. Some Basic Functionality: Downloading
"

# ╔═╡ 426c1eba-7942-42da-bd72-cd88eb66c915
download(npd,geo,overwrite=true)

# ╔═╡ cb3eac19-a970-4858-9e28-d2fcf4044005
read(npd,geo,Date(2017)) # returns an NCDataset

# ╔═╡ 3ed28f69-e864-4185-a855-0842732b3822
begin
	ds = read(npd,geo,Date(2017))
	lon  = ds["longitude"][:]
	lat  = ds["latitude"][:]
	prcp = ds["precipitation"][:,:,:] * 86400
	close(ds)
	md"Loading data from NetCDF file ..."
end

# ╔═╡ 9210d23c-ae4e-4125-827b-670a5b336577
md"Month: $(@bind imo PlutoUI.Slider(1:12,show_value=true))"

# ╔═╡ 4006623a-5708-4bbd-b507-f092932abedf
begin
	ax1.title = "Sumatra Monthly GPM Precipitation | 2017-$imo"
	contourf!(
		ax1,lon,lat,prcp[:,:,imo],
		levels=range(0,20,length=11),extendhigh=:auto
	)
	lines!(ax1,clon,clat,color=:black,linewidth=0.5)
	fig
end

# ╔═╡ Cell order:
# ╟─af53ce52-accb-11ee-2a0c-95b8bf3adea9
# ╟─dcf31c28-cbb0-4aa9-b371-72e002bfb455
# ╟─c5ce5d54-21fe-4be3-b5b4-4d68dac1a190
# ╟─b6c4ab4f-ff93-4fd4-b4cd-ede1956ed022
# ╟─f07f1d25-80f9-4017-a4ab-09b1a52db3ee
# ╟─8ad55e37-3667-4ccd-b700-15174346939b
# ╟─e9f4f15e-b23e-4d68-a1eb-ad95730135e4
# ╟─9d2ecde3-c7f7-4852-972f-18300294a2b0
# ╟─b47c46f7-5dfd-4fea-b47d-a51a3f990ca0
# ╟─d7b1b192-78d6-4f03-b8f7-273cebea1741
# ╠═22ea1049-31b9-4627-8f91-d68d2714fe74
# ╟─9eee56b4-1e3c-427c-aa0c-9e729e709b81
# ╟─8963c087-d6ec-4488-afc4-6a128d83f2c6
# ╟─047ef605-7572-4a36-95c7-4861a06946ad
# ╟─bf009093-b9b7-4137-9f45-c36d04ce2360
# ╠═426c1eba-7942-42da-bd72-cd88eb66c915
# ╠═cb3eac19-a970-4858-9e28-d2fcf4044005
# ╟─3ed28f69-e864-4185-a855-0842732b3822
# ╟─9210d23c-ae4e-4125-827b-670a5b336577
# ╟─4006623a-5708-4bbd-b507-f092932abedf
