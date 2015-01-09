import numpy as np
import numpy.ma as ma
import datetime as dt
from scaleio import *
import sys

if len(sys.argv) <= 1:
    sys.exit("\nUsage: {:s} BASE_FILE\n".format(sys.argv[0]))
initialfile = sys.argv[1]

wavel1 =   8000.
wavel2 = 100000.
dx = 200.
zheight = 20000.
taper_width = 100

pert_std = 0.1
halo = 2

nproc, rootgrps, dimdef = scale_open(initialfile, 'r+')

vardim, vardata = scale_read(nproc, rootgrps, dimdef, 'DENS', it=0)
rho = vardata[:,halo:-halo,halo:-halo]
vardim2, vardata = scale_read(nproc, rootgrps, dimdef, 'RHOT', it=0)
rhoT = vardata[:,halo:-halo,halo:-halo]
if vardim != vardim2:
    raise ValueError, 'Dimensions mismatch.'

var = rhoT / rho
#var = rhoT

#print var.shape
#print np.max(var[0,:,:])
#print np.min(var[0,:,:])

n = var.shape[2]
m = var.shape[1]
l = var.shape[0]
l2 = l / 2 + 1

fc3d = np.zeros((l, m, n), dtype='complex128')
amp3d = np.zeros((l2, m, n), dtype='float64')

for ll in xrange(l2):
    for mm in xrange(m):
        mms = min(mm, m - mm)
        for nn in xrange(n):
            nns = min(nn, n - nn)
            wn = np.sqrt(nns ** 2 + (mms*n/m) ** 2 + (ll*n*dx/zheight) **2)
            if wn <= dx * n / wavel1 and wn >= dx * n / wavel2:
                amp3d[ll, mm, nn] = 1.

pha3d = np.random.rand(l2, m, n) * 2. * np.pi
fc3d[0:l2, :, :] = amp3d * np.exp(1j * pha3d)

for ll in xrange(1, l2):
    lli = l - ll
    for mm in xrange(m):
        if mm == 0:
            mmi = 0
        else:
            mmi = m - mm
        for nn in xrange(n):
            if nn == 0:
                nni = 0
            else:
                nni = n - nn
            fc3d[lli, mmi, nni] = fc3d[ll, mm, nn]

gp3d = np.real(np.fft.ifftn(fc3d))
gp3d_std = np.std(gp3d)

for mm in xrange(m):
    for nn in xrange(n):
        dist_bd = min(mm, m - 1 - mm, nn, n - 1 - nn)
        if dist_bd < taper_width:
            taper_ratio = float(dist_bd) / taper_width
            gp3d[:, mm, nn] *= taper_ratio

gp3d /= gp3d_std
gp3d *= pert_std
var += gp3d

rhoT = rho * var
#rhoT = var

vardata[:,halo:-halo,halo:-halo] = rhoT
scale_write(nproc, rootgrps, dimdef, 'RHOT', vardim, vardata, it=0)

vardim, vardata = scale_read(nproc, rootgrps, dimdef, 'RHOT', it=0)
scale_write(nproc, rootgrps, dimdef, 'RHOT', vardim, vardata, it=0)

scale_close(rootgrps)
