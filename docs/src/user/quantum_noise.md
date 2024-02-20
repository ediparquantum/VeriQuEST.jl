# Quantum Noise

Modelling quantum noise requires the use of mixed states. The dnesity matrix (`DensityMatrix`) as opposed to the state vector (`StateVector`) represented as a `Complex` matrix and vector respectively is the data backend to use. Pure states, using state vectors output perfect ideal results, making noise modelling limited to post measurement bit flips. Initialising density matrices with `QuEST` can be done as 

```julia
env = createQuESTEnv()
num_qubits = 10
qureg = createDensityQureg(num_qubits, env)
```

which creates the pure state ``| 0 \rightangle\leftangle 0 |``. By default `QuEST` has prebuilt decoherence models. These are 

1. Damping
2. Dephasing
3. Depolarising
4. Pauli 
5. Kraus maps
6. Density matrix mixing

Note that some of the above models are available is two qubit and $N$ qubits gates.

## Damping 

To run a damping noise within the verification framework recall

```julia
# Damping
p = [p_scale*rand() for i in vertices(para[:graph])]
model = Damping(Quest(),SingleQubit(),p)
server = NoisyServer(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```  

### Example of Damping directly in QuEST

Damping noise induces single qubit amplitude decay through the use of two Kraus operators. Take density matrix, $\rho$ to represent the qureg. With probability, $p$ amplitudes are damped from the $1$ to the $0$ state.

$$\rho \rightarrow K_1\rho K_1^{\dagger} + K_2\rho K_2^{\dagger}$$

where 

$$K_1 =\begin{pmatrix} 1 & 0 \\ 0 & \sqrt{1-p}\end{pmatrix}\quad\quad K_2 =\begin{pmatrix} 0 & \sqrt{p} \\ 0 & 0\end{pmatrix}$$

The probability is a real probabilits, hence, $0 \le p \le 1$, where $p=1$ implies the amplitude of the state always damps to the zero state.

In QuEST directly this is called as

```julia
env = createQuESTEnv()
num_qubits = 1
qureg = createDensityQureg(num_qubits,env)
```
The density matrix is

```julia
2×2 Matrix{ComplexF64}:
 1.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+0.0im
```

apply an $X$ gate
```julia
pauliX(qureg,1)
```

gives 

```julia
2×2 Matrix{ComplexF64}:
 0.0+0.0im  0.0+0.0im
 0.0+0.0im  1.0+0.0im
```

So we are now in the $1$ state. Lets apply the damping function.

```julia
p = .33
mixDamping(qureg,1,p)
```

gives

```julia
2×2 Matrix{ComplexF64}:
 0.33+0.0im   0.0+0.0im
  0.0+0.0im  0.67+0.0im
```

Note that the function `get_qureg_matrix(qureg::Qureg)` will return the state vector or density matrix when called. The amplitudes of the $1$ state have "damped" proportionally to the propbability of the damping function.

### Key takeaways for the damping decoherence model


## Dephasing

To run a dephasing noise within the verification framework recall

```julia
# Dephasing
p = [p_scale*rand() for i in vertices(para[:graph])]
model = Dephasing(Quest(),SingleQubit(),p)
server = NoisyServer(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```

### Example of Dephasing directly in QuEST

With probability, $0 \le p \le 1/2$ a Paulia $Z$ gate is mixed with a density matrix qureg, $\rho$ to results in a single qubit dephasing noise on qubit, $q$. 

$$\rho \rightarrow (1-p)\rho +p Z_q \rho Z_q$$

We set up a density qureg.

```julia
env = createQuESTEnv()
num_qubits = 1
qureg = createDensityQureg(num_qubits,env)
```    
Get the details of the state

```julia
2×2 Matrix{ComplexF64}:
 1.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+0.0im
```
Apply a Pauli $Y$ gate,

```julia
rotateY(qureg,1,π/4)
```
with state details,

```julia
2×2 Matrix{ComplexF64}:
 0.853553+0.0im  0.353553+0.0im
 0.353553+0.0im  0.146447+0.0im
```
then apply a maximally mixed dephasing gate

```julia
p = 0.5
mixDephasing(qureg,1,p)
```

with new state now

```julia
2×2 Matrix{ComplexF64}:
 0.853553+0.0im       0.0+0.0im
      0.0+0.0im  0.146447+0.0im
```

### Key takeaways for the dephasing decoherence model




## Depolarising 

To run a depolarising noise within the verification framework recall

```julia
# Depolarising
p = [p_scale*rand() for i in vertices(para[:graph])]
model = Depolarising(Quest(),SingleQubit(),p)
server = NoisyServer(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```

### Example of depolarising directly in QuEST

Depolarising noise mixes a density qureg to result in single-qubit homogeneous depolarising noise. Like Dephasing noise, with probability $p$ a uniformly random noise is appied to qubit $q$. The applied noise is either Pauli $X$, $Y$, or $Z$ to $q$.

$$\rho \rightarrow (1-p)\rho +\frac{p}{3} X_q \rho X_q + Y_q \rho Y_q + Z_q \rho Z_q,$$

note that $p$ has an upper bound of $3/4$, where maximal mixing occurs and is equivalent to

$$\rho \rightarrow \left(1 - \frac{4}{3}p\right)\rho + \left(\frac{4}{3}p \right)\frac{\bar{1}}{2},$$

where $\frac{\bar{1}}{2}$ is the maximally mixed state of $q$.

In QuEST directly this is called as

```julia
env = createQuESTEnv()
num_qubits = 1
qureg = createDensityQureg(num_qubits,env)
```
The density matrix is

```julia
2×2 Matrix{ComplexF64}:
 1.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+0.0im
```

Apply, as before a $Y$ gate,


```julia
rotateY(qureg,1,π/4)
```
which has state,

```julia
2×2 Matrix{ComplexF64}:
 0.853553+0.0im  0.353553+0.0im
 0.353553+0.0im  0.146447+0.0im
```
then apply a depolarising noise,

```julia
p = 0.5
mixDepolarising(qureg,1,p)
```
which has state

```julia
2×2 Matrix{ComplexF64}:
0.617851+0.0im  0.117851+0.0im
0.117851+0.0im  0.382149+0.0im
```



### Key takeaways for the depolarising decoherence model



## Pauli

To run a Pauli noise within the verification framework recall


```julia
# Pauli
p_xyz(p_scale) = p_scale .* [rand(),rand(),rand()]
p = [p_xyz(p_scale) for i in vertices(para[:graph])]
model = Pauli(Quest(),SingleQubit(),p)
server = NoisyServer(model)
vbqc_outcome = run_verification_simulator(server,Verbose(),para)
```

### Example of Pauli directly in QuEST

In QuEST directly this is called as

```julia
env = createQuESTEnv()
num_qubits = 1
qureg = createDensityQureg(num_qubits,env)
```
The density matrix is

```julia
2×2 Matrix{ComplexF64}:
 1.0+0.0im  0.0+0.0im
 0.0+0.0im  0.0+0.0im
```


### Key takeaways for the Pauli decoherence model