
[title]: - "makeflow - Quickstart"
[TOC]
 
## Overview

[Makeflow](http://ccl.cse.nd.edu/software/makeflow/) is a workflow engine that handles large number 
of jobs. The following are characteristics of Makeflow.

* `Master/Workers paradigm`  Workers complete the tasks and transfer the data back to the master. Master 
monitors and controls the workers.
* `Parallel job execution` Jobs are executed in parallel as much as possible.
* `Fault tolerant` In case of failure, the execution of jobs are  continued from where it stopped. 
* `UNIX tool Make`  The syntax of Makeflow is similar to UNIX tool Make that allows one to easily describe the job dependencies.  

<img src="https://raw.githubusercontent.com/OSGConnect/tutorial-makeflow-quickstart/master/Figs/MWFig.png" width="400px" height="350px" />

In this tutorial, we learn (1) how to use Makeflow and (2) how to detach the master process 
from the terminal so that 
the master is alive and waits for the workers to complete, even after we log out from the submit node. We 
consider a simple example of generating Fibonacci sequence to demonstrate the usage of Makeflow. 

## tutorial files

It is convenient to start with the `tutorial` command. In the command prompt, type

	 $ tutorial makeflow-quickstart # Copies input and script files to the directory tutorial-makeflow-quickstart
 
This will create a directory `tutorial-makeflow-quickstart`. Inside the directory, you will see the following files

     fibonacci.bash                 # A simple bash script that generates the Fibonacci sequence
     fibonacci.makeflow             # The makeflow file 

The file `fibonacci.bash` is the job script and the file `fibonacci.makeflow` describes the make rules. 

The script `fibonacci.bash` takes an integer as an input argument and generates the Fibonacci 
sequence. For example, 

     $ ./fibonacci.bash 6

would print the Fibonacci sequence 1, 2, 3, 5, and 8. 

## Makeflow script

The Makeflow file `fibonacci.makeflow` describes a workflow of executing two independent jobs (Rules 1&2) followed by a
dependent job (Rule 3). See Fig. 2 for the graphical representation of the workflow. The syntax of the Makeflow file is based on the Make rules.   

<img src="https://raw.githubusercontent.com/OSGConnect/tutorial-makeflow-quickstart/master/Figs/FibFig.png" width="350px" height="300px" />

Let us take a look at the Makeflow script, 

     $ cat fibonacci.makeflow

     # Rule 1 
     fib.10.out: fibonacci.bash
         fibonacci.bash 10 > fib.10.out

     # Rule 2
     fib.20.out: fibonacci.bash
         fibonacci.bash 20 > fib.20.out

     # Rule 3 Local and depends on the output from Rule 1 and Rule 2
     fib.out: fib.10.out fib.20.out
         LOCAL paste fib.10.out fib.20.out > fib.out


In the above description, there are three Make rules.  Rules 1 and 2  execute `fibonnaci.bash` with input arguments 10 and 20, respectively. These two rules produce the output files fib.10.out and fib.20.out.  

Rules 1 and 2 don't have any dependency between them, so they would run concurrently. Rule 3 waits for the outputs 
from Rules 1 and 2. Therefore, Rule 3 is the child while Rules 1 and 2 are parents. 

Rule 3 is local. This means Rule 1 and 2 would run on remote machines while Rule 3 is executed on local machine. 


## Makeflow execution 

To run fibonacci.makeflow on OSG Connect, type 

     $ makeflow -T condor fibonacci.makeflow 
         Total rules: 3
     Starting execution of workflow: fibonacci.makeflow.
     fibonacci.bash 20 > fib.20.out
     fibonacci.bash 10 > fib.10.out
     paste fib.10.out fib.20.out > fib.out
     nothing left to do.

The argument `-T condor` submits jobs to the condor batch system. The 
last line `nothing left to do` means the workflow is completed. 

## What next?

This tutorial explains the basics of running Makeflow on OSG with a toy example of generating fibonacci sequence. Go 
through the tutorial on "makeflow-detachmaster" and  learn how to detached master from the Termianl. This is useful to 
run long running jobs on OSG. Also check 
the examples on makeflow-R and makeflow-GROMACS that show how to run real applications on OSG with Makeflow.

## Getting Help
For assistance or questions, please email the OSG User Support team  at [user-support@opensciencegrid.org](mailto:user-support@opensciencegrid.org) or visit the [help desk and community forums](http://support.opensciencegrid.org).
