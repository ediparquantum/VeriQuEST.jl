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