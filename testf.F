      program test2f
      
#include "lats.inc"
#ifdef HAVE_NETCDF
#include "netcdf.inc"

      double precision t42lats(64)
      double precision t42lons(128)
      double precision t42levs(3)
      real u(128,64,3), ucopy(128,64)
      real v(128,64)
      integer sft(128,64), sftcopy(128,64)
      integer t42
      integer ncid, rcode, nuid, nsftid, start(4), count(4)
      data t42levs/1000, 925.0, 850.0/
      
      data t42lats/
     $     0.8786379E+02, 0.8509652E+02, 0.8231291E+02, 0.7952560E+02,
     $     0.7673689E+02, 0.7394751E+02, 0.7115775E+02, 0.6836775E+02,
     $     0.6557760E+02, 0.6278735E+02, 0.5999702E+02, 0.5720663E+02,
     $     0.5441619E+02, 0.5162573E+02, 0.4883524E+02, 0.4604472E+02,
     $     0.4325419E+02, 0.4046364E+02, 0.3767308E+02, 0.3488252E+02,
     $     0.3209194E+02, 0.2930135E+02, 0.2651076E+02, 0.2372017E+02,
     $     0.2092957E+02, 0.1813897E+02, 0.1534836E+02, 0.1255775E+02,
     $     0.9767145E+01, 0.6976533E+01, 0.4185920E+01, 0.1395306E+01,
     $     -0.1395306E+01,-0.4185920E+01,-0.6976533E+01,-0.9767145E+01,
     $     -0.1255775E+02,-0.1534836E+02,-0.1813897E+02,-0.2092957E+02,
     $     -0.2372017E+02,-0.2651076E+02,-0.2930135E+02,-0.3209194E+02,
     $     -0.3488252E+02,-0.3767308E+02,-0.4046364E+02,-0.4325419E+02,
     $     -0.4604472E+02,-0.4883524E+02,-0.5162573E+02,-0.5441619E+02,
     $     -0.5720663E+02,-0.5999702E+02,-0.6278735E+02,-0.6557760E+02,
     $     -0.6836775E+02,-0.7115775E+02,-0.7394751E+02,-0.7673689E+02,
     $     -0.7952560E+02,-0.8231291E+02,-0.8509652E+02,-0.8786379E+02/
            

      t42lons(1)=0.0
      do 10 i=2,128
         t42lons(i) = t42lons(i-1)+2.8125
 10   continue
      
      xk=0.
      xm=128.*64.
      n=0
      do 30 i=1,64
         do 20 j=1,128
            u(j,i,1) = xk
            u(j,i,2) = xk
            u(j,i,3) = xk
            v(j,i)=xm
            sft(j,i)=n
            xk = xk+1.
            xm = xm+1.
            n = n+1
 20      continue
 30   continue
      
      call latserropt(LATS_VERBOSE)

      ifile = latscreate('testf.nc', LATS_PCMDI, LATS_STANDARD,
     $     LATS_HOURLY,
     $     6, 'PCMDI',
     $     'test2f', 'LATS test')
	
      t42 = latsgrid("t42", LATS_GAUSSIAN, 128, t42lons, 64,
     $     t42lats)
      levid = latsvertdim('height', 'plev', 3, t42levs)

      iuid = latsvar(ifile, 'ua', LATS_FLOAT, LATS_INSTANT, t42,
     $     levid, 'Just testing u')
      ierr = latsmissreal(ifile, iuid, 99999.0, 0.5)

      ivid = latsvar(ifile, 'va', LATS_FLOAT, LATS_INSTANT, t42,
     $     isurfid, 'Just testing v')
      ierr = latsmissreal(ifile, ivid, 1.0e20, 1.0e14)

ccc      isftid = latsvar(ifile, 'pix', LATS_INT, LATS_INSTANT,
ccc     $     t42, 0, 'Just testing sft')
ccc      ierr = latsmissint(ifile, isftid, 4)
      
      do 60 iday=1,2
         do 50 j=0,18,6
            do 40 i=1,3
               ierr = latswrite(ifile, iuid, t42levs(i), 1978, 12,
     $              iday, j, u(1,1,i))
 40         continue
            ierr = latswrite(ifile, ivid, 1000.0D0, 1978, 12, iday, j,
     $           v)
ccc            ierr = latswrite(ifile, isftid, 1000.0D0, 1978, 12, iday, j,
ccc     $           sft)
 50      continue
 60   continue
            
      ierr = latsclose(ifile)
      
      ncid = ncopn('testf.nc',NCNOWRIT,rcode)
      nuid = ncvid(ncid,'ua',rcode)
      start(1)=1
      start(2)=1
      start(3)=1
      start(4)=1
      count(1)=128
      count(2)=64
      count(3)=1
      count(4)=1
      call ncvgt(ncid,nuid,start,count,ucopy,rcode)
      do 70 i=1,64
         do 80 j=1,128
            if(u(j,i,1).ne.ucopy(j,i)) then
               print *,'u(',j,',',i,',1)=',u(j,i,1),', ucopy= ',
     $              ucopy(j,i)
               call exit(1)
            endif
 80      continue
 70   continue
ccc      nsftid = ncvid(ncid,'psl',rcode)
ccc      call ncvgt(ncid,nsftid,start,count,sftcopy,rcode)
ccc      do 100 i=1,64
ccc         do 90 j=1,128
ccc            if(sft(j,i).ne.sftcopy(j,i)) then
ccc               print *,'sft(',j,',',i,')=',sft(j,i),', sftcopy= ',
ccc     $              sftcopy(j,i)
ccc               call exit(1)
ccc            endif
ccc  90      continue
ccc 100  continue
#else
      print *,'Skipping FORTRAN test: no netCDF library'
#endif      
      end
      
            

