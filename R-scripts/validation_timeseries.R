# compare the CLM5 and MODIS 
library(ncdf4)
library(tiff)
library(Metrics)
#setwd("D:\\ZBW\\Watershed\\")
clm_data_dir="Y:\\cesm_archive\\1kmx1km_UCPR-I2000Clm50SpGs-UCPR-irrigated-calibration3-2019-07-10\\lnd\\hist\\"
modis_data_dir="D:\\ZBW\\MODIS\\MODIS_LAI\\output\\2010-2018"
clm_result_name=list.files(clm_data_dir,full.names = TRUE)
modis_result_name=list.files(modis_data_dir,full.names = TRUE)
n=4656
location=array(0,c(n,2))
landunit=array(0,c(n,9))
natveg=array(0,c(n,15))
cft=array(0,c(n,64))
result=array(0,c(n,1))
sim_result=array(0,c(3285,1))  # 3285 for daily results. 108 for monthly results
sim_corn_result=array(0,c(3285,1))
sim_wheat_result=array(0,c(3285,1))
sim_soybean_result=array(0,c(3285,1))
modis_result=array(0,c(414,1))
modis_corn_result=array(0,c(414,1))
modis_wheat_result=array(0,c(414,1))
modis_soybean_result=array(0,c(414,1))

v=seq(1,3285)
vv=seq(1,414)


for (i in v){
    print(i)
  nc=nc_open(clm_result_name[i])
  location[,1]=ncvar_get(nc=nc,varid = 'lon')
  location[,2]=ncvar_get(nc=nc,varid = 'lat')
  landunit=ncvar_get(nc=nc,varid = 'PCT_LANDUNIT')
  natveg=ncvar_get(nc=nc,varid = 'PCT_NAT_PFT')
  cft=ncvar_get(nc=nc,varid = 'PCT_CFT')
  # landunit :1 is vegetation; 2 is crop
  result=ncvar_get(nc=nc,varid='TLAI')
  index=which(landunit[,2]>60 )
  index_corn=which(landunit[,2]>60 & cft[,4]>60)
  index_wheat=which(landunit[,2]>60 & (cft[,8])>60)
  index_soybean=which(landunit[,2]>60 & cft[,10]>60)
  
  num=length(index)
  num_corn=length(index_corn)
  num_wheat=length(index_wheat)
  num_soybean=length(index_soybean)
  land_type_lon=array(0,c(num,1))
  land_type_lat=array(0,c(num,1))
  land_corn_lon=array(0,c(num_corn,1))
  land_corn_lat=array(0,c(num_corn,1))
  land_wheat_lon=array(0,c(num_wheat,1))
  land_wheat_lat=array(0,c(num_wheat,1))
  land_soybean_lon=array(0,c(num_soybean,1))
  land_soybean_lat=array(0,c(num_soybean,1))
  
  # ET and GPP should mutiple by 3600*24
  sim_result[i]=mean(result[index])
  sim_corn_result[i]=mean(result[index_corn])
  sim_wheat_result[i]=mean(result[index_wheat])
  sim_soybean_result[i]=mean(result[index_soybean])
  land_type_lon[,1]=location[index,1]
  land_type_lat[,1]=location[index,2]
  land_corn_lon[,1]=location[index_corn,1]
  land_corn_lat[,1]=location[index_corn,2]
  land_wheat_lon[,1]=location[index_wheat,1]
  land_wheat_lat[,1]=location[index_wheat,2]
  land_soybean_lon[,1]=location[index_soybean,1]
  land_soybean_lat[,1]=location[index_soybean,2]
  
  # monthly i%%12 ==0, daily i%%365==0
  if (i%%365==0 ){
    for (j in vv){
      print(j)
      img=readTIFF(modis_result_name[j], as.is = TRUE)
      modis_x=floor((land_type_lon-219.984)/0.00589)
      modis_y=floor((49.9999-land_type_lat)/0.00589)
      modis_corn_x=floor((land_corn_lon-219.984)/0.00589)
      modis_corn_y=floor((49.9999-land_corn_lat)/0.00589)
      modis_wheat_x=floor((land_wheat_lon-219.984)/0.00589)
      modis_wheat_y=floor((49.9999-land_wheat_lat)/0.00589)
      modis_soybean_x=floor((land_soybean_lon-219.984)/0.00589)
      modis_soybean_y=floor((49.9999-land_soybean_lat)/0.00589)
      modis_result_ori=array(0,c(length(modis_y),1))
      modis_result_ori_corn=array(0,c(length(modis_corn_y),1))
      modis_result_ori_wheat=array(0,c(length(modis_wheat_y),1))
      modis_result_ori_soybean=array(0,c(length(modis_soybean_y),1))
      for (m in seq(1:length(modis_y))){
       modis_result_ori[m]=img[modis_y[m,1],modis_x[m,1]]
      }
      for (m1 in seq(1:length(modis_corn_y))){
       modis_result_ori_corn[m1]=img[modis_corn_y[m1,1],modis_corn_x[m1,1]]
      }
      for (m2 in seq(1:length(modis_wheat_y))){
       modis_result_ori_wheat[m2]=img[modis_wheat_y[m2,1],modis_wheat_x[m2,1]]
      }
      for (m3 in seq(1:length(modis_soybean_y))){
       modis_result_ori_soybean[m3]=img[modis_soybean_y[m3,1],modis_soybean_x[m3,1]]
      }
      missing_index=which(modis_result_ori>100 | modis_result_ori< 0 )
      missing_index_corn=which(modis_result_ori_corn>100 | modis_result_ori_corn< 0 )
      missing_index_wheat=which(modis_result_ori_wheat>100 | modis_result_ori_wheat< 0 )
      missing_index_soybean=which(modis_result_ori_soybean>100 | modis_result_ori_soybean< 0)
      modis_result_ori[missing_index]=9999 
      modis_result_ori_corn[missing_index_corn]=9999
      modis_result_ori_wheat[missing_index_wheat]=9999
      modis_result_ori_soybean[missing_index_soybean]=9999
      modis_result[j,1]=0.1*(sum(modis_result_ori)-9999*length(missing_index))/(length(modis_result_ori)-length(missing_index))
      modis_corn_result[j,1]=0.1*(sum(modis_result_ori_corn)-9999*length(missing_index_corn))/(length(modis_result_ori_corn)-length(missing_index_corn))
      modis_wheat_result[j,1]=0.1*(sum(modis_result_ori_wheat)-9999*length(missing_index_wheat))/(length(modis_result_ori_wheat)-length(missing_index_wheat))
      modis_soybean_result[j,1]=0.1*(sum(modis_result_ori_soybean)-9999*length(missing_index_soybean))/(length(modis_result_ori_soybean)-length(missing_index_soybean))
      j=j+1
      vv=seq(j,414)
      
       if (j%%46==1){
        break
       }
      
    }
  }
  nc_close(nc)
} 

NAN_value=which(is.nan(modis_result)== 1)
NAN_value_corn=which(is.nan(modis_corn_result)==1)
NAN_value_wheat=which(is.nan(modis_wheat_result)==1)
NAN_value_soybean=which(is.nan(modis_soybean_result)==1)
modis_result[NAN_value]=mean(modis_result[NAN_value-1]+modis_result[NAN_value+1])
modis_corn_result[NAN_value_corn]=mean(modis_result[NAN_value_corn-1]+modis_result[NAN_value_corn+1])
modis_wheat_result[NAN_value_wheat]=mean(modis_result[NAN_value_wheat-1]+modis_result[NAN_value_wheat+1])
modis_soybean_result[NAN_value_soybean]=mean(modis_result[NAN_value_soybean-1]+modis_result[NAN_value_soybean+1])

# convert the clm daily results to 8 days
sim_8day_result=array(0,c(414,1))
sim_8day_corn_result=array(0,c(414,1))
sim_8day_wheat_result=array(0,c(414,1))
sim_8day_soybean_result=array(0,c(414,1))

for (m in seq(1,414)){
  
  num_year=(m-1)%/%46
  date=8*m-3*num_year
  
  if (m%%46==0){
    sim_8day_result[m]=mean(sim_result[(date-7):(date-3)])
    sim_8day_corn_result[m]=mean(sim_corn_result[(date-7):(date-3)])
    sim_8day_wheat_result[m]=mean(sim_wheat_result[(date-7):(date-3)])
    sim_8day_soybean_result[m]=mean(sim_soybean_result[(date-7):(date-3)])
  }else{
    sim_8day_result[m]=mean(sim_result[(date-7):date])
    sim_8day_corn_result[m]=mean(sim_corn_result[(date-7):date])
    sim_8day_wheat_result[m]=mean(sim_wheat_result[(date-7):date])
    sim_8day_soybean_result[m]=mean(sim_soybean_result[(date-7):date])
  }
  
  
}

out_put=cbind(sim_8day_result,modis_result)
write.table(out_put,"D:\\ZBW\\Watershed\\NEW\\calibration\\cropLAI.txt")
out_put=cbind(sim_8day_corn_result,modis_corn_result)
write.table(out_put,"D:\\ZBW\\Watershed\\NEW\\calibration\\cornLAI.txt")
out_put=cbind(sim_8day_wheat_result,modis_wheat_result)
write.table(out_put,"D:\\ZBW\\Watershed\\NEW\\calibration\\wheatLAI.txt")
out_put=cbind(sim_8day_soybean_result,modis_soybean_result)
write.table(out_put,"D:\\ZBW\\Watershed\\NEW\\calibration\\soybeanLAI.txt")
# yearly results
yearly_results=array(0,c(2,9))
for (k in seq(1,9)){
  yearly_results[1,k]=mean(sim_8day_result[(k*46-45):(k*46)])*365
  yearly_results[2,k]=mean(modis_result[(k*46-45):(k*46)])*365
}

# plot bar
color=c("green","blue")
barplot(yearly_results,xlab = "year",ylab = "GPP gC/m2/year", log="y",names.arg=seq(2010,2018),col=color,beside=TRUE)
legend("topright",legend = c("CLM5","MODIS"),col=color,fill = color,cex=1.0,box.lty = 0)
legend("top",legend = c("crop"),cex=1.0,box.lty = 0)
#plot(seq(2010,2017,length.out = 7),yearly_results[,1],type="l",xlab = "year",ylab = "ET mm/year")
#lines(seq(2010,2017,length.out = 7),yearly_results[,2],type = "l",col="blue")
#legend(2010,500,legend = c("CLM5","MODIS"), col=c("black","blue"),lty=1:1,cex=1.0,box.lty = 0)

# plot the timeseries length.out=108 for monthly , 414 for 8days
plot(seq(2010,2019,length.out = 414),sim_8day_result[1:414],type="l",xlab = "year",ylab = "GPP ",ylim = c(0,4))
points(seq(2010,2019,length.out = 414),modis_result[1:414],type="l" ,col="blue")
legend(2010,8.0,legend = c("crop"),cex=1.5,box.lty = 0)
legend(2010,7.0,legend = c("CLM5","MODIS"), col=c("black","blue"),lty=1:1,cex=1.0,box.lty = 0)
#corn
plot(seq(2010,2019,length.out = 414),sim_8day_corn_result[1:414],type="o",xlab = "year",ylab = "GPP",ylim = c(0,12))
points(seq(2010,2019,length.out = 414),modis_corn_result[1:414],type="o" ,col="blue")
legend(2010,9.0,legend = c("corn"),cex=1.5,box.lty = 0)
legend(2010,8.0,legend = c("CLM5","MODIS"), col=c("black","blue"),lty=1:1,cex=1.0,box.lty = 0)
#wheat
plot(seq(2010,2019,length.out = 414),sim_8day_wheat_result[1:414],type="l",xlab = "year",ylab = "GPP ",ylim = c(0,3))
points(seq(2010,2019,length.out = 414),modis_wheat_result[1:414],type="l" ,col="blue")
legend(2010,10.0,legend = c("wheat"),cex=1.5,box.lty = 0)
legend(2010,9.0,legend = c("CLM5","MODIS"), col=c("black","blue"),lty=1:19,cex=1.0,box.lty = 0)
#soybean
plot(seq(2010,2019,length.out = 414),sim_8day_soybean_result[1:414],type="l",xlab = "year",ylab = "GPP ",ylim = c(0,10))
points(seq(2010,2019,length.out = 414),modis_soybean_result[1:414],type="l" ,col="blue")
legend(2010,10.0,legend = c("soybean"),cex=1.5,box.lty = 0)
legend(2010,9.0,legend = c("CLM5","MODIS"), col=c("black","blue"),lty=1:19,cex=1.0,box.lty = 0)

# plot scatter
cor(modis_result,sim_8day_result)
rmse(modis_result,sim_8day_result)
plot(modis_result,sim_8day_result,xlab = "MODIS",ylab = "CLM5",pch=19,xlim = c(0,4),ylim = c(0,4))
lines(seq(-1,8),seq(-1,8))
abline(lm(sim_8day_result ~ modis_result),col="blue")
legend(0,8,legend = c("R=0.83","RMSE=1.35"),box.lty = 0)
#corn
cor(modis_corn_result,sim_8day_corn_result)
rmse(modis_corn_result,sim_8day_corn_result)
plot(modis_corn_result,sim_8day_corn_result,xlab = "MODIS",ylab = "CLM5",pch=19,xlim = c(0,9),ylim = c(0,9))
lines(seq(-1,10),seq(-1,10))
abline(lm(sim_8day_corn_result ~ modis_corn_result),col="blue")
legend(0,9,legend = c("R=0.79","RMSE=1.87"),box.lty = 0)
#wheat
cor(modis_wheat_result,sim_8day_wheat_result)
rmse(modis_wheat_result,sim_8day_wheat_result)
plot(modis_wheat_result,sim_8day_wheat_result,xlab = "MODIS",ylab = "CLM5",pch=19,xlim = c(0,8),ylim = c(0,8))
lines(seq(-1,9),seq(-1,9))
abline(lm(sim_8day_wheat_result ~ modis_wheat_result),col="blue")
legend(0,8,legend = c("R=0.84","RMSE=1.19"),box.lty = 0)
#soybean
cor(modis_soybean_result,sim_8day_soybean_result)
rmse(modis_soybean_result,sim_8day_soybean_result)
plot(modis_soybean_result,sim_8day_soybean_result,xlab = "MODIS",ylab = "CLM5",pch=19,xlim = c(0,10),ylim = c(0,10))
lines(seq(-1,11),seq(-1,11))
abline(lm(sim_8day_soybean_result ~ modis_soybean_result),col="blue")
legend(0,10,legend = c("R=0.80","RMSE=1.80"),box.lty = 0)

ET_1=as.matrix(read.table('D:\\ZBW\\Watershed\\NEW\\4cases\\case1cropET.txt'))
ET_2=as.matrix(read.table('D:\\ZBW\\Watershed\\NEW\\4cases\\case2cropET.txt'))
ET_3=as.matrix(read.table('D:\\ZBW\\Watershed\\NEW\\4cases\\case3cropET.txt'))
ET_4=as.matrix(read.table('D:\\ZBW\\Watershed\\NEW\\4cases\\case4cropET.txt'))
modis_et=as.matrix(read.table('D:\\ZBW\\Watershed\\NEW\\4cases\\modiscropET.txt'))

NAN_value=which(is.nan(modis_et)== 1)
modis_et[NAN_value]=mean(modis_et[NAN_value-1]+modis_result[NAN_value+1])
plot(seq(2016,2019,length.out=138),modis_et,ylab='ET',xlab='year',ylim=c(0,6),type='l')
lines(seq(2016,2019,length.out = 1096),ET_1,type="l" ,col="blue")
lines(seq(2016,2019,length.out = 1096),ET_2,type="l" ,col="red")
lines(seq(2016,2019,length.out = 1096),ET_3,type="l" ,col="green")
lines(seq(2016,2019,length.out = 1096),ET_4,type="l" ,col="yellow")
legend(2016,6.0,legend = c("crop"),cex=1.5,box.lty = 0)
legend(2016,5.0,legend = c("MODIS","CLM-case4"), col=c("black","yellow"),lty=1:19,cex=1.0,box.lty = 0)
