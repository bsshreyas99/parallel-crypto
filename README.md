A project by Arjun Manjunatha Rao (arjunman) and Shreyas Belur Sampath (sbelursa)

* [Project Proposal](#project-proposal)
    * [Summary](#summary)
    * [Background](#background)
    * [The Challenge](#the-challenge)
    * [Resources](#resources)
    * [Goals and Deliverables](#goals-and-deliverables)
        * [Plan to Achieve](#plan-to-achieve)
        * [Hope to Achieve](#hope-to-achieve)
        * [Deliverables](#deliverables)
    * [Platform Choice](#platform-choice)
    * [Schedule](#schedule)

# Project Proposal

## Resources

We plan to use the GPUs and CPUs on the GHC machines, and both the GPU and regular memory nodes on Bridges-2, PSC's (Pittsburgh Supercomputing Center's) flagship supercomputer. 

We will explore/implement sequential versions of the cryptographic algorithms and identify avenues of parallelism, following which we will implement multiple parallel versions of the algorithms, on frameworks like OpenMP, OpenMPI, CUDA and using techniques like SIMD.

We will also study the necessary background through textbooks and handbooks, including but not limited to:
* Basics of Cryptography lectures by Christof Paar
* A Graduate Course in Applied Cryptography by Dan Boneh and Victor Shoup
* The CUDA Handbook

## Goals and Deliverables

### *Plan to Achieve*

We will construct a library with parallel versions of existing sequential implementations of primarily two cryptographic algorithms, AES and ChaCha20. In the case we do not find a satisfactory sequential version, we will implement our own version following the steps detailed for the algorithm. 

For both the AES and ChaCha20 algorithms, we will work on parallelizing the independently computed blocks using atleast 2 framworks and techniques mentioned above. A combination of the parallelization techniques will also be explored. For implementations using CUDA, we will test and study their performances on the GPUs of both the machine types.

### *Hope to Achieve*

We also hope to implement a parallel version of the Elliptic Curve Digital Signature Algorithm (ECDSA) on the frameworks mentioned.

### *Deliverables*

Our deliverables will mainly include speedup graphs across the different frameworks coupled with the analyses of their performances using quantitative metrics. Since we will be evaluating the performance on the GHC and Bridges-2 machines, a benchmark report will also be included. Finally, we will expose the suite of parallel cryptographic algorithms we implement on C++ for public usage.

## Platform Choice

Since our project focusses on parallelizing cryptographic algorithms and also studying their performance across parallel frameworks, we will use OpenMP, CUDA and OpenMPI. We will use C++ as the implementation language due to its compatibility with all the frameworks mentioned and the fine-grained control of memory that it provides.
