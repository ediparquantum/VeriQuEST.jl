---
# To run locally as a JOSS paper
# docker run --rm --volume $PWD:/data --user $(id -u):$(id -g) --env JOURNAL=joss openjournals/inara
# To run locally just as compiled pdf
# pandoc paper.md --pdf-engine=pdflatex --from=markdown --output=draft_paper.pdf --bibliography=paper.bib --metadata link-citations=true 

# Your paper should include:
# A list of the authors of the software and their affiliations, using the correct format (see the example below).
# A summary describing the high-level functionality and purpose of the software for a diverse, non-specialist audience.
# A Statement of need section that clearly illustrates the research purpose of the software and places it in the context of related work.
# A list of key references, including to other software addressing related needs. Note that the references should include full names of venues, e.g., journals and conferences, not abbreviations only understood in the context of a specific discipline.
# Mention (if applicable) a representative set of past or ongoing research projects using the software and recent scholarly publications enabled by it.
# Acknowledgement of any financial support.
# As this short list shows, JOSS papers are only expected to contain a limited set of metadata (see example below), a Statement of need, Summary, Acknowledgements, and References sections. You can look at an example accepted paper. Given this format, a “full length” paper is not permitted, and software documentation such as API (Application Programming Interface) functionality should not be in the paper and instead should be outlined in the software documentation.
# Further: https://joss.readthedocs.io
title: 'VeriQuEST.jl: Emulating quantum verification with QuEST'
tags:
  - Julia
  - quantum computing
  - measurement based quantum computing 
  - blind quantum computing
  - quantum verification
  - emulation
  - noise
  - decoherence
authors:
  - name: Jonathan Miller
    orcid: 0000-0002-5836-1736
    equal-contrib: true
    affiliation: 1
  - name: Cica Gustiani
    orcid: 0000-0000-0000-0000
    equal-contrib: false
    affiliation: '2'
  - name: Dominik Leichtle
    orcid: 0000-0000-0000-0000
    equal-contrib: false
    affiliation: '2'
  - name: Elham Kashefi
    orcid: 0000-0000-0000-0000
    corresponding: false
    affiliation: '2'
affiliations:
  - name: School of Informatics, University of Edinburgh, 10 Crichton Street, Edinburgh EH8 9AB, United Kingdom
    index: 1
  - name: 'Laboratoire d’Informatique de Paris 6, CNRS, Sorbonne Université, 4 Place Jussieu, Paris 75005, France'
    index: 2
date: 29 Jan 2024
bibliography: paper.bib

# Optional fields if submitting to a AAS journal too, see this blog post:
# https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing
#aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
#aas-journal: Astrophysical Journal <- The name of the AAS journal.

---
<!-- The paper should be between 250-1000 words. -->
<!-- Begin your paper with a summary of the high-level functionality of your software for a non-specialist reader. Avoid jargon in this section. -->


# Summary

Verification of delegated quantum computations is a challenging task in both theory and implementation. To address the theory, methods and protocols have been developed that ouline abstract verification. Implementation will likely require a quantum network in place for certain protocols. In the mean time, specialised emulators have been developed to perform quantum computation, offering a possibility to explore verifcation numerically. Many emulators rely solely on the gate base model and do not allow for projective, mid-circuit measurements, a key component in most quantum verification protocols. In response, we present the Julia package, `RobustBlindVerification.jl` (RBV). RBV aims to emulate blind measurement based quantum computing (MBQC and UBQC) with interactive verfication in place. Quantum computation is emulated in RBV with the Julia package `QuEST.jl`, which in turn is a wrapper package, `QuEST_jll`, developed with `BinaryBuilder.jl` [@BinaryBuilder2022] to reproducibally call the `C` library, `QuEST` [@QuESTJones2019]. RBV is developed based on the work by @PRXQuantum.2.040302, herein referred to as 'the protocol'. The protocol is an example of robust blind quantum computation (RBVQC). It is a formal verification protocol with minimal overhead, beyond computational repetition and resistant to constant noise whilst mainting security. 

<!-- We also require that authors explain the research applications of the software. -->
# Statement of need

There are many quantum computing paradigms, notably the gate or circuit based model is the most popular [**Cite**]. It is limited by most hardware providers not capable of performing mid-circuit, adpative and projective measurements [**Cite**]. The measurement-base quantum computing (MBQC) paradigm conversely is predicated on this very capability [**Cite**]. It turns out that MBQC can utilise projective measurements to offer secure delegated QC over a quantum network between clients and servers. This leads to the need for efficient, secure and verifiable delegated access. Trust in the security, data usages, compuation and algorithm implementation is not a given for delegated QC. Many protocols have been implemented to address these issues. Advancements in verification has relied on verification assuming only uncorrelated noise [@Gheorghiu_2019], verification assuming reliable state preparation per qubit [@Kapourniotis2019nonadaptivefault], verification requiring more than one server and entanglement distillation [@MorimaeFujii2013] or verification with the assumption that a verifier has access to post-quantum cryptography unbeakable by a quantum prover  [@Mahadev2022ClassicalVerification]. Such results fall short of a robust verification protocol that does not suffer from costly process or are inflexible to noise. To respond to these shortcomings and to address the problem for bounded-error quantum polynomial (BQP) computations a verification protocol is implemented[@PRXQuantum.2.040302]. It is known that the complexity class BQP can efficiently solve binary descision problems with quantum computers. Further, the protocol is robust to constant noise and maintain security.


The basis for this verification protocol is universal blind quantum computation (UBQC), which extends meaurement based quantum computation. Commonly, a client with minimal quantum capabilities, maybe only state preparation or only measurement is theorised, and an all powerful conceptual server is connected to this client over a quantum network. MBQC works by updating the basis angle qubits are measured in by the outcomes of previous qubits. By keeping a set of secret basis angles which are incorpoarated into measurement basis, the client can perform its quantum computation free from the server being able to ascertain any informatoin [**CHECK**]. So a qubit is initialised by the client as $|+_{\theta}\rangle$, where $\theta$ is the rotational angle, but there is another angle, $\delta$ such that when the basis for measurment is updated, the server is told to measure with $\tilde{\theta} + \delta + r\pi$, where $\tilde{\theta}$ is the updated angle based on previous measurement outcomes and $r$ is a one time pad random bit used to help correct measurements [**CITE BLIND**]. To turn UBQC into  robust verification quantum computation (RVBQC), the protocol calls for the use of multiple rounds to run the computation along with some test rounds.

The protocol is designed such that verification is separated into the execution of $N$ rounds, $C$ rounds are the algorithm to be run (e.g., the computation round) and $T = N-C$ test rounds. Test rounds contain traps which can detect malicious or noisy behaviour of the server. The algorithm for test rounds has the same underlying stucture save for state initialisations and the method of adaptive basis updates. After $N$ rounds, a classical analysis is conducted and a result computed whether the server and/or the computation were to be trusted. The computation round is prepared and executed with UBQC, whereas the test rounds utilise a trapification strategy to conduct tests against the server. The test rounds use a strategy that splits some qubits into traps and some into dummies. The traps and the dummies are prepared according to some randomness, which though the UBQC will have determinsitic outcomes that can me tested. For each test round the traps and the dummies are compared such that all trap qubit outcomes must pass a verification equation, if any one trap fails the whole test round fails. The outcome to these tests for each round are aggregated. The aggregate count of test rounds that passed the test must exceed a predetermined amount, based on parameters of the protocol. The mode repsonse for the computation round must be greater than half the number of computation rounds. The results of the test and computation rounds dictate the trust of the server. RVBQC implements the protocol under these requirements. For an in depth understanding see @@PRXQuantum.2.040302.

# Core features and functionality

There are three core features. Firstly, the user can simply run standard MBQC if they so choose. Secondly, the user can specify to use UBQC. Thirdly, the user can run the verification protocol. Since MBQC and UBQC are universal [**CITE**] the outcomes are the same. If a user wants to explore with noise models, then the RVBQC is designed to seemlessly offer these by specifying the noise model in the server struct (e.g., `NoisyServer(model)` for `model` being the specified noise model). Julia is a transparent programming language and all functionality is available to the user. If one wishes to become acquainted with the details see the public GitHub repository for [`VeriQuEST`](https://github.com/fieldofnodes/VeriQuEST.jl).



# Future plans

The concept of a client and server in the quantum sense requires a quantum internet. There are means to simulate a single Hilbert space for the client and the server such that the client can initialise a single qubit in the space and through Bell entanglement teleport qubit states to select qubits in the server. The server does not know these state due to the entanglement. That has not been incorporated here, instead the client initalises all qubits in the state in its own density matrix or state vector, then the server duplicates the state. The client state is no longer considered. The server state is acted upon with noise, entanglement and measurements. Here we restrict what information the client sends to the server to keep the emulation of blindness in tact. A future work will be to introduce this client-server algorithm to better emulate the relationship.

The noise models used in this package are standard models, but may not accurately capture hardware noise realistically. To address this whole quantum state Kraus maps, density mixing, double qubit and more custom single qubit models are being developed. 



# Acknowledgements

We acknowledge contributions from QSL, NQCC,...???

# References