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

For both the AES and ChaCha20 algorithms, we will work on parallelizing the independently computed blocks using atleast 2 frameworks and techniques mentioned above. A combination of the parallelization techniques will also be explored. For implementations using CUDA, we will test and study their performances on the GPUs of both the machine types.

### *Hope to Achieve*

We also hope to implement a parallel version of the Elliptic Curve Digital Signature Algorithm (ECDSA) on the frameworks mentioned.

### *Deliverables*

Our deliverables will mainly comprise of speedup graphs across the different frameworks coupled with the analyses of their performances using quantitative metrics. Since we will be evaluating the performance on the GHC and Bridges-2 machines, a benchmark report will also be included. Finally, we will expose the suite of parallel cryptographic algorithms we implement on C++ for public usage.

## Platform Choice

Since our project focusses on parallelizing cryptographic algorithms and also studying their performance across parallel frameworks, we will use OpenMP, CUDA and OpenMPI. We will use C++ as the implementation language due to its compatibility with all the frameworks mentioned and the fine-grained control of memory that it provides.

## Schedule

* Week 1 (03/31): Complete project proposal and finalize parallelism frameworks. Explore/implement sequential versions of cryptographic algorithms.
* Week 2 (04/07): Identify sequential bottlenecks and parallelize AES using OpenMP, OpenMPI and CUDA.
* Week 3 (04/14): Identify sequential bottlenecks and parallelize ChaCha20 using OpenMP, OpenMPI and CUDA. Milestone report.
* Week 4 (04/21): Identify sequential bottlenecks and parallelize ECDSA using OpenMP, OpenMPI and CUDA. 
* Week 5 (04/28): Benchmark report and performance analyses. Final report and poster.

# Milestone Report

## Milestone Summary

We have conducted a comprehensive analysis of the existing sequential implementations of the ChaCha and AES algorithms. Initially, our focus was centered on utilizing Botan, a C++ cryptography library, as our baseline. However, as these algorithms already contain some degree of parallelism in the form of SIMD and AVX vector instructions, we desired to explore alternative avenues of parallelization and concentrated solely on the algorithms themselves.

For the ChaCha algorithm, we selected an implementation developed by Ginurx to serve as our sequential baseline reference. Given that existing implementations employ optimizations such as loop unrolling, we developed our own sequential version to comprehend the performance improvements that could be gained through parallelism. The ChaCha algorithm is primarily comprised of a key expansion phase, in which a 256-bit key is padded with predetermined constants, a nonce, and a block number. The expanded key is subsequently permuted through rounds that feature a series of XOR, addition, and rotation operations. We have identified that the quarter round phases - the crux of each round phase - can be parallelized by harnessing OpenMP's thread-level parallelism to achieve optimal performance.

In a similar vein, we adopted a comparable approach for the AES algorithm, which has a similar structure to the ChaCha algorithm. However, the AES algorithm entails matrix multiplications to permute the columns, which can be parallelized by executing the operations on GPUs using the cuBLAS library - a highly optimized matrix multiplication library.


## Updates to Goals and Deliverables

Up to this point, we have understood the cryptographic algorithms in question, and have successfully produced their sequential versions, whilst simultaneously pinpointing areas of potential parallelism. Regrettably, due to the substantial amount of time invested in comprehending the reference implementations, we have been unable to implement the parallelizations as mentioned in the previously defined schedule. As a consequence, the parallelization of ECDSA may not be realizable within the designated timeframe of this project. Despite this setback, we will explore alternative avenues of parallelization, such as message encryption batching and kernel composition for AES and ChaCha and we remain confident in our ability to fulfill our planned objectives and analyses. 


## Deliverables for the Final Presentation

We will be displaying speedup graphs across the different frameworks coupled with a detailed analyses of their performances using quantitative metrics. 


## Half-Weekly Schedule

| Due Date | Task | Assignee |
|----------|------|----------|
| April 22 | AES parallelization using ISPC | Shreyas |
| April 22 | ChaCha parallelization using ISPC | Arjun |
| April 26 | AES parallelization using CUDA  | Shreyas |
| April 26 | ChaCha parallelization using CUDA  | Arjun |
| April 30 | AES parallelization using OpenMP | Shreyas |
| April 30 | ChaCha parallelization using OpenMP | Arjun |
| May 4 | Final report | Shreyas |
| May 4 | Poster | Arjun |
