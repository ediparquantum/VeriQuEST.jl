---
title: 'RobustBlindVerification.jl: Emulating quantum verification with QuEST'
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
    affiliation: "1, 2" # (Multiple affiliations must be quoted)
  - name: Author Without ORCID
    equal-contrib: true # (This is how you can denote equal contributions between multiple authors)
    affiliation: 2
  - name: Author with no affiliation
    corresponding: true # (This is how to denote the corresponding author)
    affiliation: 3
  - given-names: Ludwig
    dropping-particle: van
    surname: Beethoven
    affiliation: 3
affiliations:
 - name: Lyman Spitzer, Jr. Fellow, Princeton University, USA
   index: 1
 - name: Institution Name, Country
   index: 2
 - name: Independent Researcher, Country
   index: 3
date: 13 August 2017
bibliography: paper.bib

# Optional fields if submitting to a AAS journal too, see this blog post:
# https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing
aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
aas-journal: Astrophysical Journal <- The name of the AAS journal.
---

# Summary

We present here the Julia package, `RobustBlindVerification.jl` (RBV) to emulate quantum verification protocols in ideal and noisy settings. The RBV package is a quantum computing emulator, which uses the `QuEST.jl` package (from QuEST, a C library wrapped packaged using `BinaryBuilder.jl` for reproducible 3rd-party binaries) to perform the quantum operations. RBV is based on the measurement based quantum computing (MBQC) paradigm, and uses universal blind quantum computing to hide computations from detection. Verfication is implemented via trapification strategies and multiple rounds of computation. The verification algorithm is implemneted to account for noise and naive malicious behaviour or uncorrelated noise.

Refine and proof ...

# Statement of need

The rise of quantum computers gives rise to a variety of path dependent access points to such computers. Delegated quantum computing may likely be the dominant means most can access a quantum computer. One party's access may require secrecy in their computation. Another party, or the same, may need to verify results or computations are trustworty. Formal methods in quantum verification have been developed in theory. Many of these methods rely on quantum networks, mid-circuit measurement and qubit capabilities beyond the current near-term offering. In preparation for the aforementioned to become reality, quanutm emulators offer cheap computational access in many toy problems, along with an ability to test theoretical results.

RBV is to-date (and at the authors undersatnding) the only emulator which implements a simulated blind quantum computation, let alone the verification protool [cite]. Many quantum computing emulators also only focus on the gate-based model, whilst some implement MBQC [Cite] many do not allow for noise models beyond uncorrelated models, which do not utilise density matrix backends. Many emulators are also focused on python-based libraries [cite]. RBV is based in Julia and calls on a C library. QuEST is a remarkable library that is capable of use agnostically to the machinery accessing the library.

What else .... 
Cite    .....

# State of the field

Verification is becoming a core component in the quatnum computing stack, in addition to confirming computation is done as expected, verification can act to determine the noisyness of a give n machine. 

Add more here ...

# Core features and functionality
 
Core features:

1. Run MBQC
2. Run UBQC
3. Run Verification noiseless
4. Run Verification with server that changes the measurement angle (malicious)
5. Run Verification with suite of standard decoherence models with Kraus maps and density matrix mixing
6. Run test rounds on random graphs for general analysis
7. Should be useful in multithreading/cores
8. Could be used with GPU with certain algorithms
9. ...
10. Uses Julia's multiple dispatch to implement different noise models efficiently
11. Should have a generic idea of noise if user wants to implement their own

# Examples

1. Present examples using simple graphs
2. Present Grover MBQC as example
3. Present Rgover in verification
4. Present Random graphs in noise expression

# Citations

Leave here for reference
Citations to entries in paper.bib should be in
[rMarkdown](http://rmarkdown.rstudio.com/authoring_bibliographies_and_citations.html)
format.

If you want to cite a software repository URL (e.g. something on GitHub without a preferred
citation) then you can do it with the example BibTeX entry below for @fidgit.

For a quick reference, the following citation commands can be used:
- `@author:2001`  ->  "Author et al. (2001)"
- `[@author:2001]` -> "(Author et al., 2001)"
- `[@author1:2001; @author2:2001]` -> "(Author1 et al., 2001; Author2 et al., 2002)"

# Figures

Figures can be included like this:
![Caption for example figure.\label{fig:example}](figure.png)
and referenced from text using \autoref{fig:example}.

Figure sizes can be customized by adding an optional second parameter:
![Caption for example figure.](figure.png){ width=20% }

# Acknowledgements

We acknowledge contributions from Brigitta Sipocz, Syrtis Major, and Semyeong
Oh, and support from Kathryn Johnston during the genesis of this project.

# References