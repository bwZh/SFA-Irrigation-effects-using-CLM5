result1=as.matrix(read.table("D:\\ZBW\\MODIS\\Validation\\irrigation_new\\monthly_FSDS.txt"))
result2=as.matrix(read.table("D:\\ZBW\\MODIS\\Validation\\irrigation_new\\Bowenratio.txt"))
result3=as.matrix(read.table("D:\\ZBW\\MODIS\\Validation\\irrigation_new\\monthly_FSR.txt"))
modis_result=as.matrix(read.table("D:\\ZBW\\MODIS\\Validation\\irrigation\\modis_GPP.txt"))
result1=result3/result1
# result=result/30
modis_result=array(modis_result,c(46,9))
modis_monthly=array(0,c(12,1))
for (i in seq(1:12)){
  if (i==12){
    modis_monthly[i]=mean(modis_result[((4*i)-3):46,])*30
  }else{
    modis_monthly[i]=mean(modis_result[((4*i)-3):(4*i),])*30
  }
  
}
#plot(modis_result,xlab=expression('hi'[5]*'there'[6]^8*'you'[2]))
#legend(0,4,legend = c(expression('hi'[5]*'there'[6]^8*'you'[2])))
# runoff
result2[1,]=result2[1,]+result3[1,]
result2[2,]=result2[2,]+result3[2,]

spatial1=as.matrix((read.table("D:\\ZBW\\MODIS\\Validation\\irrigation_new\\sptial_TWS.txt")))
spatial2=as.matrix((read.table("D:\\ZBW\\MODIS\\Validation\\irrigation_new\\sptial_ZWT.txt")))
spatial3=as.matrix((read.table("D:\\ZBW\\MODIS\\Validation\\irrigation_new\\sptial_QDRAI.txt")))
spatial2[1,]=spatial2[1,]+spatial3[1,]
spatial2[2,]=spatial2[2,]+spatial3[2,]


library(plot3D)
library(raster)
library(rgdal)
library(sp)
river=shapefile("D:\\ZBW\\Watershed\\DEM\\river_pro.shp")
#----------------------------------------------start to plot
png("D:\\ZBW\\Watershed\\results\\albedo.png",width = 9000,height = 3000,res=300)
#png("D:\\ZBW\\Watershed\\results\\cornnpool.png",width = 8000,height = 3000,res=300)
par(mfrow=c(1,2),mar=c(4,5,4,5))
par(lwd=2,cex.axis=2)

# ZWT and TWS annual changes

plot(seq(2010,2019,length.out = 3285),result1[,1],type="l",col="blue",xlab = "year",
     ylab = "TWS m",ylim=c(2000,2500),xaxt="n",cex.lab=1.2)
axis(1,at=seq(2010,2018,by=1),cex=1.5)
lines(seq(2010,2019,length.out = 3285),result1[,2],type="l" ,col="green")
legend(2010,2500,legend = c(expression('CLM'[rainfed]),expression('CLM'[irrig])), col=c("blue","green"),lty=c(1,1),cex=1.2,box.lty = 0)

plot(seq(2010,2019,length.out = 3285),result2[,1],type="l",col="blue",xlab = "year",
     ylab = "ZWT m",ylim=c(9,7.5),xaxt="n",cex.lab=1.2)
axis(1,at=seq(2010,2018,by=1),cex=1.5)
lines(seq(2010,2019,length.out = 3285),result2[,2],type="l" ,col="green")
legend(2010,7.5,legend = c(expression('CLM'[rainfed]),expression('CLM'[irrig])), col=c("blue","green"),lty=c(1,1),cex=1.2,box.lty = 0)
# monthly changes

plot(seq(1,12,length.out = 12),result1[1,],type="l",col="blue",xlab = "month",
     ylab = "Albedo ",ylim=c(0,0.4),xaxt="n",cex.lab=2)
axis(1,at=seq(1,12,by=1),cex.axis=2)
lines(seq(1,12,length.out = 12),result1[2,],type="l" ,col="green")
# lines(seq(1,12,length.out = 12), modis_monthly,type="l",col="red",lty=4)
legend(0.8,0.4,legend = c(expression('CLM'[rainfed]),expression('CLM'[irrig])), col=c("blue","green"),lty=c(1,1),cex=2,box.lty = 0)

plot(seq(1,12,length.out = 12),result2[1,],type="l",col="blue",xlab = "month",
     ylab = "Bowen ratio ",ylim=c(0,9),xaxt="n",cex.lab=2)
axis(1,at=seq(1,12,by=1),cex.axis=2)
lines(seq(1,12,length.out = 12),result2[2,],type="l" ,col="green")
legend(0.8,9,legend = c(expression('CLM'[rainfed]),expression('CLM'[irrig])), col=c("blue","green"),lty=c(1,1),cex=2,box.lty = 0)

plot(seq(1,12,length.out = 12),result3[1,],type="l",col="blue",xlab = "month",
     ylab = "Decomposition rate",ylim=c(0.2,0.45),xaxt="n",cex.lab=2)
axis(1,at=seq(1,12,by=1),cex.axis=2)
lines(seq(1,12,length.out = 12),result3[2,],type="l" ,col="green")
legend(0.8,0.45,legend = c(expression('CLM'[rainfed]),expression('CLM'[irrig])), col=c("blue","green"),lty=c(1,1),cex=2,box.lty = 0)

graphics.off()


#----------------------------------------------
## plot spatial
png("D:\\ZBW\\Watershed\\results\\spatialTWSZWT.png",width = 4800,height = 2700,res=300)
par(mfrow=c(1,2),mar=c(4,1.8,4,1.8))
par(lwd=2)
diff=spatial1[,2]-spatial1[,1]
diff_spatial=array(diff,c(60,60))
image2D(z=diff_spatial,x=seq(551600,610600,length.out = 60),y=seq(104500,163500,length.out = 60),res=300,
        main=expression('TWS(CLM'[irrig]*'-CLM'[rainfed]*')'),zlim=c(20,200),col=jet2.col(12),rasterImage=F,axes=FALSE,clab = "mm",cex.main=1.5)
plot(river,xlim=c(551600,610600),ylim=c(104500,163500),col="white",add=TRUE)     

diff=spatial2[,2]-spatial2[,1]
diff_spatial=array(diff,c(60,60))
image2D(z=diff_spatial,x=seq(551600,610600,length.out = 60),y=seq(104500,163500,length.out = 60),res=300,
        main=expression('ZWT(CLM'[irrig]*'-CLM'[rainfed]*')'),zlim=c(-0.20,-0.03),col=jet2.col(12),rasterImage=F,axes=FALSE,clab = "m",cex.main=1.5)
plot(river,xlim=c(551600,610600),ylim=c(104500,163500),col="white",add=TRUE)   



graphics.off()

