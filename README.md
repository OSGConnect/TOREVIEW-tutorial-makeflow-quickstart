
[title]: - "Makeflow - Quickstart"
[TOC]
 
## Overview

[Makeflow](http://ccl.cse.nd.edu/software/makeflow/) is a workflow engine that handles a large number 
of jobs. The following are characteristics of Makeflow.

*    `Master/Workers paradigm`  The master monitors and controls the workers while the workers complete the tasks. 
master monitors and controls the workers.
*    `Parallel job execution` Jobs are executed in parallel as much as possible.
*    `Fault tolerant` In case of failure, the jobs are continued from where they are stopped. 
*    `UNIX tool Make` The syntax of Makeflow is similar to the popular UNIX tool Make. The Make rules are 
convenient in describing the job dependencies.  

<img src="https://raw.githubusercontent.com/OSGConnect/tutorial-makeflow-quickstart/master/Figs/MWFig.png" width="450px" height="350px" />

In this tutorial, we learn how to (1) use Makeflow and (2) detach the master process 
from the terminal.  

## Tutorial files

It is convenient to start with the `tutorial` command. In the command prompt, type

     $ tutorial makeflow-quickstart # Copies input and script files to the directory tutorial-makeflow-quickstart
 
This will create a directory `tutorial-makeflow-quickstart`. Inside the directory, you will see the following files

     fibonacci.bash                       # A simple bash script that generates the Fibonacci sequence
     fibonacci.makeflow                   # Makeflow file 
     submit_makeflow_to_local_condor.sh   # Script to execute the makeflow file as a local condor job

`fibonacci.makeflow` is the makeflow file.   `fibonacci.bash` is a shell
script to generate Fibonacci sequence for a given integer. For example, 

     $ ./fibonacci.bash 6

would print Fibonacci sequence 1, 2, 3, 5, and 8. 

## Makeflow script and parent child relationship

The figure shows the graphical representation of `fibonacci.makeflow`.  It describes two independent jobs (Rules 1&2) followed by a dependent job (Rule 3). The syntax of the Makeflow file is based on Make rules.   

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

In the above description, there are three Make rules.  Rules 1 and 2  execute `fibonnaci.bash` with input arguments 10 and 20, respectively. These two rules produce the output files fib.10.out and fib.20.out.  Rules 1 and 2 are 
independent, so they would run concurrently. Rule 3 waits for completion of Rules 1&2. 

## Executing Makeflow script as a local condor job. 

We may execute Makeflow either as an interactive process or a detached process. It is a good practice to 
run the master process in the detached mode rather than in an interactive mode. There are several ways 
to detach the master process from the terminal, such as `SCREEN`, `tmux`, and condor job as `local universe`. 

Here we run the master process as a local job in condor universe with the shell   
script `submit_makeflow_to_local_condor.sh`.

     $ submit_makeflow_to_local_condor.sh fibonacci.makeflow
     Submitting job(s).
     1 job(s) submitted to cluster 367027.

This shell command executes the makeflow file `fibonacci.makeflow` as a local condor job. Further details on 
condor local jobs are given in the section `Additional details on Makeflow execution: Interactive mode and detached mode` at the end of this tutorial. 

Check the job status

    $ condor_q username -wide
    -- Submitter: login01.osgconnect.net : <192.170.227.195:21720> : login01.osgconnect.net
     ID      OWNER            SUBMITTED     RUN_TIME ST PRI SIZE CMD
    19150583.0   dbala           4/1  11:54   0+00:01:54 R  0   0.4  makeflow -T condor fibonacci.makeflow
    19150584.0   dbala           4/1  11:54   0+00:00:40 I  0   0.0  condor.sh fibonacci.bash 20 > fib.20.out
    19150585.0   dbala           4/1  11:54   0+00:00:20 I  0   0.0  condor.sh fibonacci.bash 10 > fib.10.out

The above output shows that the master is running and two workers are waiting in queue. The master process 
is a local condor job so it starts quickly. The worker jobs are distributed on OSG machines and they are 
waiting for resources. All jobs would complete in few minutes.

## What's next?

This tutorial explains the basics of Makeflow on the OSG with a toy example of generating 
fibonacci sequence. Next, check the examples on makeflow-R and makeflow-GROMACS that show how 
to run real applications on the OSG with Makeflow.

## Getting Help
For technical questions about Makeflow,  contact [Cooperative Computing Lab (cclab)](http://ccl.cse.nd.edu/software/help/).
For general assistance or questions related to running the jobs on OSG, please email the OSG User Support team  at [user-support@opensciencegrid.org](mailto:user-support@opensciencegrid.org) or visit the [help desk and community forums](http://support.opensciencegrid.org).
                                     

## Additional details on Makeflow execution: Interactive mode and detached mode  

Makeflow runs in the interactive or detached mode. Interactive mode is
is okay if the workflow finishes in few minutes. Often this is not the case. Therefore, it is a good 
practice to run the workflow in the detached mode. 

### Interactive mode 

To run fibonacci.makeflow in the interactive mode (takes only few minutes to complete), type

     $ makeflow -T condor fibonacci.makeflow
         Total rules: 3
     Starting execution of workflow: fibonacci.makeflow.
     fibonacci.bash 20 > fib.20.out
     fibonacci.bash 10 > fib.10.out
     paste fib.10.out fib.20.out > fib.out
     nothing left to do.

The argument `-T condor` submits jobs to the condor batch system. The
last line `nothing left to do` means the workflow is completed.

### Detached mode

To run fibonacci.makeflow in the detached mode on the OSG Connect, the condor local job is 
highly recommended. The other options are  `SCREEN`,  `nohup`, and `tmux`. Here, we provide details 
of the local condor job.

To run fibonacci.makeflow as a local condor job,

     $ submit_makeflow_to_local_condor.sh fibonacci.makeflow 

The script `submit_makeflow_to_local_condor.sh` creates a file `local_condor_makeflow.submit` and submits 
the job with the command `condor_submit local_condor_makeflow.submit`. 

Let us take a look at the file `local_condor_makeflow.submit`

    $ cat local_condor_makeflow.submit
    universe = local
    getenv = true
    executable = /usr/bin/makeflow
    arguments = -T condor fibonacci.makeflow
    log = local_condor.log
    queue

This is a job description file for HTCondor job schedular. The first line says that the job universe is local, so the 
job would run on the login node itself. The executable for the job is `/usr/bin/makeflow` with an argument `-T condor fibonacci.makeflow`. The keyword `queue` is the start button that submits the above three lines to the 
HTCondor batch system.



