# compare the irrigation effects spatial
library(ncdf4)
library(plot3D)
library(raster)
library(rgdal)
library(sp)

clm_data_irri="Y:\\cesm_archive\\1kmx1km_UCPR-I2000Clm50SpGs-UCPR-wwrainfed-calibration3-2019-10-09\\lnd\\hist\\"
clm_data_rain="Y:\\cesm_archive\\1kmx1km_UCPR-I2000Clm50SpGs-UCPR-noirrigated-calibration3-2019-07-15\\lnd\\hist\\"
clm_result_name_rain=list.files(clm_data_rain,full.names = TRUE)
clm_result_name_irri=list.files(clm_data_irri,full.names = TRUE)
n=4656
landunit=array(0,c(n,9))
natveg=array(0,c(n,15))
cft=array(0,c(n,64))
result=array(0,c(n,16))
# sim_result=array(0,c(3285,8))
# sim_corn_result=array(0,c(3285,8))
# sim_wheat_result=array(0,c(3285,8))
# sim_soybean_result=array(0,c(3285,8))
# spatial=array(0,c(60,60))
v=seq(1,3285)

for (i in v){
  print(i)
  nc_rain=nc_open(clm_result_name_rain[i])
  nc_irri=nc_open(clm_result_name_irri[i])
  #  landunit=ncvar_get(nc=nc_rain,varid = 'PCT_LANDUNIT')
  #  cft=ncvar_get(nc=nc_rain,varid = 'PCT_CFT')
  # landunit :1 is vegetation; 2 is crop
  
  
  result[,1]=(ncvar_get(nc=nc_rain,varid='QFLX_EVAP_TOT')+result[,1])
  result[,2]=(ncvar_get(nc=nc_irri,varid='QFLX_EVAP_TOT')+result[,2])
  result[,3]=(ncvar_get(nc=nc_rain,varid='QOVER')+result[,3])
  result[,4]=(ncvar_get(nc=nc_irri,varid='QOVER')+result[,4])
  result[,5]=(ncvar_get(nc=nc_rain,varid='QDRAI')+result[,5])
  result[,6]=(ncvar_get(nc=nc_irri,varid='QDRAI')+result[,6])
  result[,7]=(ncvar_get(nc=nc_rain,varid='ZWT')+result[,7])
  result[,8]=(ncvar_get(nc=nc_irri,varid='ZWT')+result[,8])
  result[,9]=(ncvar_get(nc=nc_rain,varid='TWS')+result[,9])
  result[,10]=(ncvar_get(nc=nc_irri,varid='TWS')+result[,10])
  result[,11]=(ncvar_get(nc=nc_rain,varid='QIRRIG')+result[,11])
  result[,12]=(ncvar_get(nc=nc_irri,varid='QIRRIG')+result[,12])
  result[,13]=(ncvar_get(nc=nc_rain,varid='GPP')+result[,13])
  result[,14]=(ncvar_get(nc=nc_irri,varid='GPP')+result[,14])
  result[,15]=(ncvar_get(nc=nc_rain,varid='NEE')+result[,15])
  result[,16]=(ncvar_get(nc=nc_irri,varid='NEE')+result[,16])  
  

  
  nc_close(nc_irri)
  nc_close(nc_rain)
  
} 

# fluxes: mutiple by 3600*24 
result[,1:6]=result[,1:6]*3600*24
result[,11:16]=result[,11:16]*3600*24
result[,7:10]=result[,7:10]

write.table(result[,1:2],"D:\\ZBW\\Watershed\\NEW\\irrigation\\irrigation_new\\spatial\\sptial_ET.txt")
write.table(result[,3:4],"D:\\ZBW\\Watershed\\NEW\\irrigation\\irrigation_new\\spatial\\sptial_ROVER.txt")
write.table(result[,5:6],"D:\\ZBW\\Watershed\\NEW\\irrigation\\irrigation_new\\spatial\\sptial_RDRAI.txt")
write.table(result[,7:8],"D:\\ZBW\\Watershed\\NEW\\irrigation\\irrigation_new\\spatial\\sptial_ZWT.txt")
write.table(result[,9:10],"D:\\ZBW\\Watershed\\NEW\\irrigation\\irrigation_new\\spatial\\sptial_TWS.txt")
write.table(result[,11:12],"D:\\ZBW\\Watershed\\NEW\\irrigation\\irrigation_new\\spatial\\sptial_QIRRIG.txt")
write.table(result[,13:14],"D:\\ZBW\\Watershed\\NEW\\irrigation\\irrigation_new\\spatial\\sptial_GPP.txt")
write.table(result[,15:16],"D:\\ZBW\\Watershed\\NEW\\irrigation\\irrigation_new\\spatial\\sptial_NEE.txt")
color=c("blue","green")




diff=(result[,2]-result[,1])/3285*30


result=array(0,c(n,3))
location=read.table("D:\\ZBW\\Watershed\\NEW\\DEM.txt",header= TRUE,sep = ",")
result[,1]=location[,5]
result[,2]=location[,6]
result[,3]=diff
r=rasterFromXYZ(result)
domain=shapefile("D:\\ZBW\\Watershed\\NEW\\LULC\\domain_pro.shp")
river=shapefile("D:\\ZBW\\Watershed\\NEW\\LULC\\river.shp")
plot(r,axes=FALSE,col=jet2.col(12),main='summerET CLM5-MODIS',box=FALSE)
plot(domain,add=TRUE)
plot(river,add=TRUE,col='blue')
