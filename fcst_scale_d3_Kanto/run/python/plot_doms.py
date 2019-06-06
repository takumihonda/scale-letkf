import numpy as np
from datetime import datetime
#from datetime import timedelta
import os
import sys

from plot_common import get_gdims, prep_proj_multi, read_ens2d_split, def_cmap

import matplotlib.pyplot as plt


def main(INFO, itime, exp_l, scale_np_l, quick):
 
    lon_ll = 125.0
    lon_ur = 145.0
    lat_ur = 44.0
    lat_ll = 26.0
    
    lon_ll = 95.0
    lon_ur = 175.0
    lat_ur = 55.0
    lat_ll = 15.0

    blon = 135.0
    blat = 35.0
    lat2 = 40.0
   
    PLOT_DIMS = {"mem_l":INFO["mem_l"], 
                 "lon_ll":lon_ll, "lon_ur":lon_ur, 
                 "lat_ll":lat_ll, "lat_ur":lat_ur, 
                 "blon":blon, "blat":blat, "lat2":lat2, 
                 "nvar":"U",
                 }

    # D1
    dir = os.path.join(INFO["top"], exp_l[0], INFO["ctime"], "fcst")
    PLOT_DIMS["dir"] = dir
    GDIMS, PLOT_DIMS = get_gdims(scale_np, PLOT_DIMS)

    LON_L = {exp_l[0]: GDIMS["lon2d"]}
    LAT_L = {exp_l[0]: GDIMS["lat2d"]}

    for idx, exp in enumerate(exp_l):
       if idx == 0:
          continue 

       dir = os.path.join(INFO["top"], exp, INFO["ctime"], "fcst")
       PLOT_DIMS["dir"] = dir
    
       GDIMS, PLOT_DIMS = get_gdims(scale_np_l[idx], PLOT_DIMS)

       LON_L[exp] = GDIMS["lon2d"]
       LAT_L[exp] = GDIMS["lat2d"]

    fig, (ax1) = plt.subplots(1, 1, figsize=(6.0, 5.0))
    fig.subplots_adjust(left=0.06, bottom=0.03, right=0.98, top=0.93, 
                        wspace=0.2, hspace=0.1)
   
    c_l = ["k", "k", "k"]
    ax_l = [ax1]
    m_l = prep_proj_multi(ax_l, PLOT_DIMS, quick)
    for idx, exp in enumerate(exp_l):
      x1, y1 = m_l[0](LON_L[exp], LAT_L[exp])

      
      CONT = ax1.contourf(x1, y1, LON_L[exp])#, colors=c_l[idx])
    plt.show()
    sys.exit()
   

    
    
    fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(12.0, 5.0))
    fig.subplots_adjust(left=0.06, bottom=0.03, right=0.98, top=0.93, 
                        wspace=0.2, hspace=0.1)
    
    ax_l = [ax1, ax2, ax3]
    m_l = prep_proj_multi(ax_l, PLOT_DIMS, quick)
    
    x1, y1 = m_l[0](GDIMS["lon2d"], GDIMS["lat2d"])
    
    #cmap = plt.cmap.jet
    cmap = "jet"
  
    fac = 1.0

    unit = "(" + PLOT_DIMS["unit"] + ")"
    if nvar == "CAPE":
      tvar = nvar 
#      unit = r'(J kg$^{-1}$)'
    elif nvar == "U" or nvar == "V":
      tvar = nvar
    elif nvar == "RAIN":
      tvar = nvar 
      if tlev > 0:
        fac = GDIMS["time"][tlev] - GDIMS["time"][tlev-1] 
      else: 
        print("!Unit for RAIN is not accurate!")
        fac = 3600
      unit = "(mm/" + str(fac/3600) + "h)"
    else:
      tvar = nvar
  
    cmap_f, cmap_s, cnorm_f, cnorm_s, levs, levs_s = def_cmap(nvar, np.max(np.abs(evar))*fac)

    tit_l = ["Ensemble mean\n" + tvar, 
             "Ensemble spread\n" + tvar, 
             "Maximum\n" + tvar]
    num_l = ["(a)","(b)","(c)"]
    tit = "D2 ensemble forecast"
  
    for idx, ax in enumerate(ax_l):
    
      levels = levs

      if idx == 0:
         var = np.mean(evar[:,:,:]*fac, axis=0)
         cmap = cmap_f
         cnorm = cnorm_f
      elif idx == 1:
         var = np.std(evar[:,:,:]*fac, axis=0, ddof=1)
         levels = levs_s
         cmap = cmap_s
         cnorm = cnorm_s
      elif idx == 2:
         var = evar.max(axis=0)*fac
         cmap = cmap_f
         cnorm = cnorm_f
  
      SHADE1 = ax.contourf(x1, y1, var, cmap=cmap, 
                           levels=levels, norm=cnorm, 
                           extend='both')
    
    
    # color bar
      pos = ax.get_position()
      cb_h = pos.height
      #ax_cb = fig.add_axes([pos.x1+0.01, pos.y0, 0.015, cb_h])
      ax_cb = fig.add_axes([pos.x0+0.01, pos.y0-0.06, pos.width-0.01, 0.02])
    
      CB1 = plt.colorbar(SHADE1, cax=ax_cb, orientation = 'horizontal')
      CB1.ax.tick_params(labelsize=8)    

      ax.set_title(tit_l[idx], size=14, loc = 'center')
      ax.text(0.01, 1.03, num_l[idx],
              verticalalignment='bottom', horizontalalignment='left',
              transform=ax.transAxes, color='k', fontsize=12)
  
      ax.text(1.00, 1.01, unit,
              verticalalignment='bottom', horizontalalignment='right',
              transform=ax.transAxes, color='k', fontsize=12)

    fig.suptitle(tit, fontsize=18)
  
  
    time_info = "Init: " + itime.strftime('%m/%d/%Y %H:%M:%S UTC') + \
                "\nFT=" + "{0:.1f}".format(GDIMS["time"][tlev]/3600) + "h"
     
    foot = "_FT" + str(int(GDIMS["time"][tlev])).zfill(6) + "s_i" + \
           itime.strftime('%Y%m%d%H%M%S') 

    if nvar != "CAPE" and nvar != "RAIN":
       time_info += "\nZ=" + "{0:.1f}".format(GDIMS["z"][zlev]/1000) + "km" 
       foot += "z" + "{0:.1f}".format(GDIMS["z"][zlev]/1000) + "km"

    fig.text(0.99, 0.97, time_info,
              verticalalignment='top', horizontalalignment='right',
              color='k', fontsize=10)
  
    ofig = tvar + foot

    if not quick:
      png_dir = os.path.join("png",itime.strftime('%Y%m%d'))
      os.makedirs(png_dir, exist_ok=True)
      plt.savefig(os.path.join(png_dir, ofig + ".png"), 
                  bbox_inches="tight", pad_inches = 0.1)
      plt.clf()
      plt.close('all')
    else:
      print(ofig)
      plt.show()

  

###################

top = "/work/hp150019/f22013/SCALE-LETKF/scale-5.3.2/OUTPUT"
exp = "TEST_exp_d2"
scale_np_org = 256
scale_np = 4

itime = datetime(2019, 1, 30, 0, 0)

nvar_l = ["CAPE", "RAIN"]

tlev = 1
zlev = 30

quick = True
#quick = False

exp_l = ["TEST_exp_d1", "TEST_exp_d2", "TEST_exp_d3"]
scale_np_l = [192, 256, 256]

mem_l = []

mems = 8
for m in range(mems):
    mem = str(m+1).zfill(4)
    mem_l.append(mem)

INFO = {"top":top, "exp":exp, "ctime":itime.strftime('%Y%m%d%H%M%S'), 
        "SCALE_NP":scale_np, "SCALE_NP_ORG":scale_np_org, "mem_l":mem_l}

for nvar in nvar_l:
  main(INFO, itime, exp_l, scale_np_l, quick)
