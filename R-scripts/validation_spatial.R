# 1kmx1km spatial compare results
library(ncdf4)
library(plot3D)
library(tiff)
library(raster)
library(rgdal)
#setwd("D:\\ZBW\\Watershed\\")
data_dir="Y:\\cesm_archive\\1kmx1km_UCPR-I2000Clm50SpGs-UCPR-wwrainfed-cal3-vegmodify-2019-10-12\\lnd\\hist\\"
modis_data_dir="D:\\ZBW\\MODIS\\MODIS_ET\\output\\2010-2018"
result_name=list.files(data_dir,full.names = TRUE)
modis_result_name=list.files(modis_data_dir,full.names = TRUE)
n=4656
location=array(0,c(n,2))
ET_result_spring=array(0,c(n))
ET_result_summer=array(0,c(n))
ET_result_autumn=array(0,c(n))
ET_result_winter=array(0,c(n))

modis_result_spring=array(0,c(n,1))
modis_result_summer=array(0,c(n,1))
modis_result_autumn=array(0,c(n,1))
modis_result_winter=array(0,c(n,1))

v=seq(1,3286)
vv=seq(1,414)

for (i in v){
  print(i)
  num_year=(i-1)%/%365
  season=i-num_year*365
  nc=nc_open(result_name[i])
  location[,1]=ncvar_get(nc=nc,varid = 'lon')
  location[,2]=ncvar_get(nc=nc,varid = 'lat')
  if (season>=60 & season <=151){
    ET_result_spring=ncvar_get(nc=nc,varid='QFLX_EVAP_TOT')+ET_result_spring
  }else if(season>=152 & season<=243){
    ET_result_summer=ncvar_get(nc=nc,varid='QFLX_EVAP_TOT')+ET_result_summer
  }else if(season>=244 & season<=334){
    ET_result_autumn=ncvar_get(nc=nc,varid='QFLX_EVAP_TOT')+ET_result_autumn
  }else{
    ET_result_winter=ncvar_get(nc=nc,varid='QFLX_EVAP_TOT')+ET_result_winter
  }
    
  

#  GPP_result=ncvar_get(nc=nc,varid = "GPP")+GPP_result
  nc_close(nc)
  if (i%%365==0 ){
    for (j in vv){
      print(j)
      num_year_modis=(j-1)%/%46
      season_modis=j-num_year_modis*46
      img=readTIFF(modis_result_name[j], as.is = TRUE)
      modis_x=floor((location[,1]-219.984)/0.00589)
      modis_y=floor((49.9999-location[,2])/0.00589)
      modis_temp_result=array(0,c(length(modis_y),1))
      for (m in seq(1,n)){
        modis_temp_result[m,1]=img[modis_y[m],modis_x[m]]
      }
      
      missing_index=which(modis_temp_result>32700 | modis_temp_result< -32700 )
      modis_temp_result[missing_index]= 0
      
      if (season_modis>=9 & season_modis<=19){
        modis_result_spring=modis_result_spring+modis_temp_result
      }else if(season_modis>=20 & season_modis<=31){
        modis_result_summer=modis_result_summer+modis_temp_result
      }else if(season_modis>=32 & season_modis<=42){
        modis_result_autumn=modis_result_autumn+modis_temp_result
      }else{
        modis_result_winter=modis_result_winter+modis_temp_result
      }
     
      j=j+1
      vv=seq(j,414)
      
      if (j%%46==1){
        break
      }
    }
  }

}

  ET_result_spring=(ET_result_spring/828)
  ET_result_summer=(ET_result_summer/828)*3600*24
  ET_result_autumn=(ET_result_autumn/819)*3600*24
  ET_result_winter=(ET_result_winter/810)*3600*24

  modis_result_spring=(modis_result_spring/108)*0.1
  modis_result_summer=(modis_result_summer/108)*0.125*0.1
  modis_result_autumn=(modis_result_autumn/99)*0.125*0.1
  modis_result_winter=(modis_result_winter/108)*0.125*0.1
 write.table(ET_result_summer,"D:\\ZBW\\Watershed\\NEW\\calibration\\spatial_CLM_ET.txt")
 write.table(modis_result_summer,"D:\\ZBW\\Watershed\\NEW\\calibration\\spatial_MODIS_ET.txt")
 write.table(diff,"D:\\ZBW\\Watershed\\NEW\\calibration\\diff_ET_percentage.txt")
 
 diff=(modis_result_summer[,1]-ET_result_summer)/ET_result_summer*100
 result=array(0,c(n,3))
 location=read.table("D:\\ZBW\\Watershed\\NEW\\DEM.txt",header= TRUE,sep = ",")
 result[,1]=location[,5]
 result[,2]=location[,6]
 result[,3]=diff
 r=rasterFromXYZ(result)
 domain=shapefile("D:\\ZBW\\Watershed\\NEW\\LULC\\domain_pro.shp")
 river=shapefile("D:\\ZBW\\Watershed\\NEW\\LULC\\river.shp")
 plot(r,axes=FALSE,col=colors,main='summerET CLM5-MODIS',box=FALSE,zlim=c(-100,100))
 colors=c('red','orange','pink','white','white','yellow','green','blue')
 plot(domain,add=TRUE)
 plot(river,add=TRUE,col='blue')
 