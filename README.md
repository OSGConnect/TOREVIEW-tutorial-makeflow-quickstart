
[title]: - "Makeflow - Quickstart"
[TOC]
 
## Overview

[Makeflow](http://ccl.cse.nd.edu/software/makeflow/) is a workflow engine that handles large number 
of jobs. The following are characteristics of Makeflow.

*    `Master/Workers paradigm`  Workers complete the tasks and transfer the data back to the master. Master 
monitors and controls the workers.
*    `Parallel job execution` Jobs are executed in parallel as much as possible.
*    `Fault tolerant` In case of failure, the execution of jobs are  continued from where it stopped. 
*    `UNIX tool Make` The syntax of Makeflow is similar to UNIX tool Make that allows one to easily describe the job dependencies.  

<img src="https://raw.githubusercontent.com/OSGConnect/tutorial-makeflow-quickstart/master/Figs/MWFig.png" width="450px" height="350px" />

In this tutorial, we learn (1) how to use Makeflow and (2) how to detach the master process 
from the terminal so that 
the master is alive and waits for the workers to complete, even after we log out from the submit node. We 
consider a simple example of generating Fibonacci sequence to demonstrate the usage of Makeflow. 

## Tutorial files

It is convenient to start with the `tutorial` command. In the command prompt, type

     $ tutorial makeflow-quickstart # Copies input and script files to the directory tutorial-makeflow-quickstart
 
This will create a directory `tutorial-makeflow-quickstart`. Inside the directory, you will see the following files

     fibonacci.bash                       # A simple bash script that generates the Fibonacci sequence
     fibonacci.makeflow                   # Makeflow file 
     submit_makeflow_to_local_condor.sh   # Script to execute the makeflow file as a local condor job

`fibonacci.makeflow` is the makeflow file that contains the make rules.  `fibonacci.bash` is the job 
script which generates the Fibonacci sequence for a given integer . For example, 

     $ ./fibonacci.bash 6

would print the Fibonacci sequence 1, 2, 3, 5, and 8. 

## Makeflow script and parent child relationship

The Makeflow file `fibonacci.makeflow` describes a workflow of executing two independent jobs (Rules 1&2) followed by a
dependent job (Rule 3). See Fig. 2 for the graphical representation of the workflow. The syntax of the Makeflow file is based on the Make rules.   

<img src="https://raw.githubusercontent.com/OSGConnect/tutorial-makeflow-quickstart/master/Figs/FibFig.png" width="400px" height="300px" />

Let us take a look at the Makeflow script, 

     $ cat fibonacci.makeflow

     # Rule 1  Outputfile = fib.10.out, Inputfile = fibonacci.bash
     fib.10.out: fibonacci.bash
        fibonacci.bash 10 > fib.10.out

     # Rule 2  Outputfile = fib.20.out, Inputfile = fibonacci.bash
     fib.20.out: fibonacci.bash
        fibonacci.bash 20 > fib.20.out

     # Rule 3  Local and depends on the output from Rules 1 and 2 
     fib.out: fib.10.out fib.20.out
        LOCAL paste fib.10.out fib.20.out > fib.out

In the above description, there are three Make rules.  Rules 1 and 2  execute `fibonnaci.bash` with input arguments 10 and 20, respectively. These two rules produce the output files fib.10.out and fib.20.out.  

Rules 1 and 2 don't have any dependency between them, so they would run concurrently. Rule 3 waits for the outputs 
from Rules 1 and 2. Therefore, Rule 3 is the child while Rules 1 and 2 are parents. 

Rule 3 is local. This means Rule 1 and 2 would run on remote machines while Rule 3 is executed on local machine. 

## Executing Makeflow script 

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

## Detach Master process from the terminal

In the above execution, the master process runs in the interactive mode. It is a good idea to run the master 
process in the detached mode. There are several ways to detach the master process from the terminal, such as `SCREEN`, `tmux`, and condor job 
as `local universe`. 

Here we detach the master process from the terminal with condor local job using a 
simple script `submit_makeflow_to_local_condor.sh`.

     $ submit_makeflow_to_local_condor.sh fibonacci.makeflow
     Submitting job(s).
     1 job(s) submitted to cluster 367027.

This shell command executes the makeflow file `fibonacci.makeflow` as a local condor job. Further details on 
condor local jobs are given in the section `Additional details on condor local job` at the end of this tutorial. 

Check the job status

    $ condor_q username -w
    -- Submitter: login01.osgconnect.net : <192.170.227.195:21720> : login01.osgconnect.net
     ID      OWNER            SUBMITTED     RUN_TIME ST PRI SIZE CMD
    19150583.0   dbala           4/1  11:54   0+00:01:54 R  0   0.4  makeflow -T condor fibonacci.makeflow
    19150584.0   dbala           4/1  11:54   0+00:00:40 I  0   0.0  condor.sh fibonacci.bash 20 > fib.20.out
    19150585.0   dbala           4/1  11:54   0+00:00:20 I  0   0.0  condor.sh fibonacci.bash 10 > fib.10.out

The above output shows that the master is running and the two workers are waiting in the queue. The master process 
is a local condor job so it starts quickly. The two worker jobs are distributed on OSG machines and they are 
waiting for resources. All jobs would complete in few minutes.

## What next?

This tutorial explains the basics of Makeflow on OSG with a toy example of generating fibonacci sequence. Go 
through the tutorial on "makeflow-detachmaster" and  learn the details of how to detached master from the 
Terminal. This is useful to 
run long running jobs on OSG. Also check 
the examples on makeflow-R and makeflow-GROMACS that show how to run real applications on OSG with Makeflow.

## Getting Help
For technical questions about Makeflow,  contact [Cooperative Computing Lab (cclab)](http://ccl.cse.nd.edu/software/help/).
For general assistance or questions related to running the jobs on OSG, please email the OSG User Support team  at [user-support@opensciencegrid.org](mailto:user-support@opensciencegrid.org) or visit the [help desk and community forums](http://support.opensciencegrid.org).
                                     

## Additional details on condor local job

The execution of the submit script, 

     $ submit_makeflow_to_local_condor.sh fibonacci.makeflow 

creates the file `submit_makeflow_to_local_condor.sh`. This is the  description file for HTCondor job. Let us 
take a look at the file `local_condor_makeflow.submit`

    $ cat local_condor_makeflow.submit
    universe = local
    getenv = true
    executable = /usr/bin/makeflow
    arguments = -T condor fibonacci.makeflow
    log = local_condor.log
    queue


This is the HTcondor job description file.  The first line says that the job universe is local and the job would
run on the submit node. The executable for the job is `/usr/bin/makeflow` with an argument `-T condor fibonacci.makeflow`. The keyword `queue` is the start button
that submits the above three lines to the HTCondor batch system.



