using PowerModels

module solvelf
using ..PowerModels
export solvelf_pm
# Function for solving the LF and extracting valuable information.
function solvelf_pm(data0)
    data = PowerModels.parse_file(data0) # Parse the data file to a dictionary 
    # Solving the load flow problem using PowerModels.jl
    result = compute_ac_pf(data)
    update_data!(data, result["solution"])
    flows = calc_branch_flow_ac(data)
    update_data!(result["solution"], flows)
    Sb = result["solution"]["baseMVA"] # Base power of the system

    return Sb, result, data
end
end # module


module ymatrix
using ..PowerModels
export yexmatrix, ymatrixload
# Function for creating the expanded admittance matrix.
function yexmatrix(data)
    # Admittance matrix
    Y = calc_admittance_matrix(data).matrix 
    # Expanded admittance matrix to real and imaginary parts [YII YIR; YRI YRR]
    Yreal = real(Y)
    Yimag = imag(Y)
    Y_ex = zeros(eltype(Yreal), 2*size(Y, 1), 2*size(Y, 2)) # Preallocate the expanded matrix
    Y_ex[1:2:end, 1:2:end] .= Yreal # Fill the real part of the expanded matrix
    Y_ex[2:2:end, 2:2:end] .= Yreal # Fill the real part of the expanded matrix
    Y_ex[1:2:end, 2:2:end] .= Yimag # Fill the imaginary part of the expanded matrix
    Y_ex[2:2:end, 1:2:end] .= -Yimag # Fill the imaginary part of the expanded matrix
    return Y_ex
end

# Function for creating the load admittance matrix.
function ymatrixload(m,n,vm,va,PL0,QL0)
    vR = vm*cos(va)
    vI = vm*sin(va)
    BIR = QL0/vm^2*((n-2)vR^2/vm^2+1) - PL0/vm^2*((m-2)vR*vI/vm^2)
    GII = PL0/vm^2*((m-2)vI^2/vm^2+1) - QL0/vm^2*((n-2)vR*vI/vm^2)
    GRR = PL0/vm^2*((m-2)vR^2/vm^2+1) + QL0/vm^2*((n-2)vR*vI/vm^2)
    BRI = QL0/vm^2*((n-2)vI^2/vm^2+1) + PL0/vm^2*((m-2)vR*vI/vm^2)


    YL = [GII -BIR ; BRI GRR]
    return YL
end 
end # module


module ssmatrix
export ssmatrixclgen
export ssmatrixgen1d2q
# Functions for creating space state matrix of dynamic devices.
function ssmatrixclgen(H,KD,f,Ra,Xd,vm,va,pg,qg,Sb,Sbg)
    # Parameters of the synchronous generator in the p.u. global system.
    ra = Ra*Sb/Sbg
    xd = Xd*Sb/Sbg
    h = H * Sbg/Sb # Verification needed
    kd = KD * Sbg/Sb # Verification needed

    #  Equilibrium point
    phi = atan(qg,pg) # Power factor
    i = conj((pg + 1im*qg)/(vm)) # Current phasor
    iabs = abs(i) # Current magnitude
    E = vm + ra*i + 1im*xd*i # Internal voltage phasor
    e = abs(E) # Internal voltage magnitude
    b = angle(E) # Internal voltage angle (beta)
    # v = vd + j*vq
    vd0 = vm*sin(b)
    vq0 = vm*cos(b)
    id0 = iabs*sin(phi + b)
    iq0 = iabs*cos(phi + b)
    w0 = 2*pi*f

    # Calculated constants of the state space matrices
    a11 = -kd/(2*h)
    a12 = 0
    a21 = w0
    a22 = 0

    b11 = 0
    b12 = (-e)/(2*h)
    b21 = 0
    b22 = 0

    c11 = 0
    c12 = 0
    c21 = 0
    c22 = 0

    d11 = -ra
    d12 = xd
    d21 = -xd
    d22 = -ra

    auxa = [a11 a12; a21 a22]
    auxb = [b11 b12; b21 b22]
    auxc = [c11 c12; c21 c22]
    auxd = [d11 d12; d21 d22]

    # State space matrix in its own dq frame.
    Di = inv(auxd)
    Ci = (-1)*Di*auxc #  Verification needed
    Bi = auxb*Di
    Ai = auxa+auxb*Ci # Verification needed

    #Rotation to the IR frame 
    A, B, C, D = IRframe(Ai,Bi,Ci,Di,va,b,vd0,vq0,id0,iq0)

    return A, B, C, D
end

function ssmatrixgen1d2q(H,KD,f,Ra,Xd,Xq,Xl,Xdp,Xqp,Xdpp,Xqpp,Td0p,Tq0p,Td0pp,Tq0pp,vm,va,pg,qg,Sb,Sbg)
    w0 = 2*pi*f
    # Parameters of the synchronous generator in p.u.
    ra = Ra*Sb/Sbg
    xd = Xd*Sb/Sbg
    xq = Xq*Sb/Sbg
    xl = Xl*Sb/Sbg
    xdp = Xdp*Sb/Sbg
    xqp = Xqp*Sb/Sbg
    xdpp = Xdpp*Sb/Sbg
    xqpp = Xqpp*Sb/Sbg
    td0p = Td0p*w0
    tq0p = Tq0p*w0
    td0pp = Td0pp*w0
    tq0pp = Tq0pp*w0
    h = H * Sbg/Sb # Verification needed
    kd = KD * Sbg/Sb # Verification needed

    # Calculated parameters of the synchronous generator in p.u.
    xad = xd-xl
    xaq = xq-xl
    xfd = (xdp-xl)*xad/(xad-xdp+xl)
    rfd = (xad+xfd)/td0p
    x1d = (xdpp-xl)*xfd*xad/(xad*xfd-(xdpp-xl)*(xad+xfd))
    r1d = (x1d+xad*xfd/(xad+xfd))/td0pp
    x1q = (xqp-xl)*xaq/(xaq-xqp+xl)
    r1q = (xaq+x1q)/tq0p
    x2q = (xqpp-xl)*x1q*xaq/(xaq*x1q-(xqpp-xl)*(xaq+x1q))
    r2q = (x2q+xaq*x1q/(xaq+x1q))/tq0pp
 

    # Equilibrium point
    phi = atan(qg,pg) # Power factor
    i = conj((pg + 1im*qg)/(vm)) # Current phasor
    iabs = abs(i) # Current magnitude
    b = atan(iabs*xq*cos(phi)-iabs*ra*sin(phi),vm + iabs*ra*cos(phi)+iabs*xq*sin(phi)) # Verification needed Internal voltage angle (beta)
    vd0 = vm*sin(b)
    vq0 = vm*cos(b)
    id0 = iabs*sin(phi + b)
    iq0 = iabs*cos(phi + b)
    ifd0 = (vq0+ra*iq0+xd*id0)/xad
    i1d0 = 0
    i1q0 = 0
    i2q0 = 0
    waq0 = -xaq*iq0+xaq*i1q0+xaq*i2q0
    wad0 = -xad*id0+xad*ifd0+xad*i1d0
    xauxd = 1/(1/xad+1/xfd+1/x1d)
    xauxq = 1/(1/xaq+1/x1q+1/x2q)

    # Calculated constants of the state space matrices
    a11 = -kd/(2*h)
    a12 = 0
    a13 = -iq0*xauxd/(2*h*xfd)
    a14 = -iq0*xauxd/(2*h*x1d)
    a15 = id0*xauxq/(2*h*x1q)
    a16 = id0*xauxq/(2*h*x2q)
    a21 = w0 
    a22 = 0
    a23 = 0
    a24 = 0
    a25 = 0
    a26 = 0
    a31 = 0
    a32 = 0
    a33 = -w0*rfd/xfd*(1-xauxd/xfd) #-1/Td0p #
    a34 = -w0*rfd/xfd*(-xauxd/x1d)
    a35 = 0
    a36 = 0
    a41 = 0
    a42 = 0
    a43 = -w0*r1d/x1d*(-xauxd/xfd)
    a44 = -w0*r1d/x1d*(1-xauxd/x1d)
    a45 = 0
    a46 = 0
    a51 = 0
    a52 = 0
    a53 = 0
    a54 = 0
    a55 = -w0*r1q/x1q*(1-xauxq/x1q)
    a56 = -w0*r1q/x1q*(-xauxq/x2q)
    a61 = 0
    a62 = 0
    a63 = 0
    a64 = 0
    a65 = -w0*r2q/x2q*(-xauxq/x1q)
    a66 = -w0*r2q/x2q*(1-xauxq/x2q)

    b11 = (waq0+iq0*xauxd)/(2*h) 
    b12 = -(wad0+id0*xauxq)/(2*h) 
    b21 = 0
    b22 = 0
    b31 = -w0*rfd*xauxd/xfd #(xd-xdp)/td0p#-w0*rfd/xfd*xauxd 
    b32 = 0
    b41 = -w0*r1d*xauxd/x1d
    b42 = 0
    b51 = 0
    b52 = -w0*r1q*xauxq/x1q 
    b61 = 0
    b62 = -w0*r2q*xauxq/x2q

    c11 = 0
    c12 = 0
    c13 = 0
    c14 = 0
    c15 = -xauxq/x1q
    c16 = -xauxq/x2q
    c21 = 0
    c22 = 0
    c23 = xauxd/xfd
    c24 = xauxd/x1d
    c25 = 0
    c26 = 0

    d11 = -ra
    d12 = xl+xauxq
    d21 = -xl-xauxd
    d22 = -ra

    # Auxiliar matrices
    auxa = [a11 a12 a13 a14 a15 a16; a21 a22 a23 a24 a25 a26; a31 a32 a33 a34 a35 a36; a41 a42 a43 a44 a45 a46; a51 a52 a53 a54 a55 a56; a61 a62 a63 a64 a65 a66]
    auxb = [b11 b12; b21 b22; b31 b32; b41 b42; b51 b52; b61 b62]
    auxc = [c11 c12 c13 c14 c15 c16; c21 c22 c23 c24 c25 c26]
    auxd = [d11 d12; d21 d22]

    # State space matrix in its own dq frame.
    Di = inv(auxd) #-iabs/vm^2*[vq0 vd0; vq0 vd0] +
    Ci = (-1)*Di*auxc #  Verification needed
    Bi = auxb*Di
    Ai = auxa+auxb*Ci # Verification needed

    #Rotation to the IR frame 
    A, B, C, D = IRframe(Ai,Bi,Ci,Di,va,b,vd0,vq0,id0,iq0)

    return A, B, C, D
end

#Rotation to the IR frame 
function IRframe(Ai,Bi,Ci,Di,va,b,vd0,vq0,id0,iq0)
    d = (1)*(va + b) # Delta angle (q axis and R axis)
    R = [-cos(d) sin(d); sin(d) cos(d)] #Rotation matrix * [-1 0;0 1]
    tv = zeros(2,size(Ai,1)) 
    tv[1,2] = vq0
    tv[2,2] = -vd0
    ti = zeros(2,size(Ai,1))
    ti[1,2] = iq0
    ti[2,2] = -id0
    B = Bi*R
    A = Ai+Bi*tv 
    C = R\(Ci+Di*tv-ti)
    D = R\Di*R # = Di 
    return A, B, C, D
end
end # module



