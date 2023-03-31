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

## Summary

We intend to implement parallel versions of popularly used cryptographic algorithms including but not limited to AES, ChaCha, and Elliptical curve cryptographic algorithms. With their wide adoption in almost every real world application and computationally intensive mathematical operations and high throughput requirement, parallel implementations in order to improve performance, scalability, utilization, and resistance to attacks becomes cardinal. For each algorithm we explore, we intend to understand the most suited parallelization technique out of SIMD, thread-level parallelism using OpenMP, data parallelism using CUDA, and distributed computing using MPI and create a library with efficient parallel implementations of cryptographic algorithms in C++.

## Background

The great progress in processor speeds over the years have helped us advance in many ways; fields such as Machine Learning have become popular now that processors can finally deliver enough compute to run these algorithms on scale but it also made some of the systems we design vulnerable. Some algorithms we aim to parallelize due to their ubiquitous use and scope for parallelism include AES, ChaCha, and ECC algorithms.
AES or Advanced Encryption standard is a block cipher that involves a series of operations including substitution, permutation, and XOR operations. ChaCha is a stream cipher that involves a series of addition, rotation, and XOR operations. Elliptical Curve Cryptography or ECC involves operations such as scalar multiplication, point addition, and point doubling. 

### *Parallelizing cryptographic algorithms*
In AES and Chacha, we hope to effectively leverage SIMD instructions in order to parallelize substitution and permutation operations. While the XOR operation may benefit from thread-level parallelism as in OpenMP or data parallel execution on GPUs using CUDA. Finally, in ECC, scalar multiplication is the most computationally expensive operation and we hope to parallelize these using SIMD instructions, OpenMP, or CUDA depending on best performance observed. Scope for parallelizing point addition and point doubling operations will also be explored using SIMD and OpenMP.

## The Challenge

Considering AES, the potential challenges may include the following: 
* Data dependence of mathematical operations
* Memory access conflicts
* Workload imbalance among the different parallel components
* Side-channel attacks may be introduced along with new security vulnerabilities

For ChaCha on the other hand, the following may pose to be a challenge in addition to the above stated ones:
* Different branching instructions and diverging paths may impact parallel performance
Finally, considering ECC, additional challenges may include:
* Variable length operations may not be effectively batched for parallelism
* Communication overhead may be unavoidable while using distributed systems for performance

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
