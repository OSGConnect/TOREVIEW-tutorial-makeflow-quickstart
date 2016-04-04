
[title]: - "makeflow - Quickstart"
[TOC]
 
## Overview

[Makeflow](http://ccl.cse.nd.edu/software/makeflow/) is a workflow engine that handles large number 
of jobs. The following are characteristics of Makeflow.

     **Master/Workers paradigm**  A master process monitors and controls the workers for completing the tasks and transfering the data.  
     **Parallel job execution** Jobs are executed in parallel as much as possible.
     **Fault tollerent** In case of failure, the execution of jobs are  continued from where it stopped. 
     **UNIX tool Make**  The syntax of Makeflow is similar to UNIX tool `Make` that allows one to easily describe the job dependencies.  

![fig 1](https://raw.githubusercontent.com/OSGConnect/tutorial-makeflow-quickstart/master/Figs/MWFig.png =250px)

In this tutorial, we learn (1) how to use makeflow and (2) how to detach the master process from the terminal so that 
the master is alive and waits for the workers to complete, even after we log out from the submit node.  We consider a 
simple example of generating Fibonacci sequence to deomonstate the usage of Makeflow. 

## tutorial files

It is convenient to start with the `tutorial` command. In the command prompt, type

	 $ tutorial makeflow-quickstart # Copies input and script files to the directory tutorial-makeflow-quickstart
 
This will create a directory `tutorial-makeflow-quickstart`. Inside the directory, you will see the following files

     fibonacci.bash                 # A simple bash script that generates the Fibonacci sequence
     fibonacci.makeflow             # The makeflow file 
     local_condor_makeflow.submit  # HTcondor file to detach the master process from the terminal

The file `fibonacci.bash` is the job script, the file `fibonacci.makeflow` describes the make rules, and the 
file `local_condor_makeflow.submit` is the HTCondor description that runs the master process as local condor job. 

The script `fibonacci.bash` takes an integer as an input argument and generates the Fibonacci 
sequence. For example, 

     $ ./fibonacci.bash 6
     1
     2
     3
     5
     8

## Makeflow script

The makeflow file `fibonacci.makeflow` describes a workflow of executing two independent jobs (Rules 1&2) followed by a
dependent job (Rule 3). See Fig. 2 for the graphical representation of the workflow. The syntax of the makeflow file is based on the Make rules.   

![fig 2](https://raw.githubusercontent.com/OSGConnect/tutorial-makeflow-quickstart/master/Figs/FibFig.png)

Let us take a look at the makeflow script, 

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

## How to run the master as a detached process?

In the above description of makeflow execution, the master process runs interactively in the terminal. And the master process keeps track of the workers that are distributed on OSG machines. It is okay to run makeflow from the terminal for short jobs.The workflow of generating Fibonacci sequence takes a few minutes to complete. What if you want to run several jobs that may run for several days and weeks. If you log out from the submit node, the master process 
will be killed.  

It is a good idea to run makeflow in the detached mode. There are several ways to detach the master process from the 
terminal, such as nohup, SCREEN, tmux, and condor local job. 

We recommend to run the master process as a local condor job on the submit node.

## Run master process as a local condor job. 

Let us take a look at the file `local_condor_makeflow.submit`

      $ cat local_condor_makeflow.submit 
      universe = local                        
      executable = /usr/bin/makeflow
      arguments = -T condor fibonacci.makeflow
      queue 

This is the HTcondor job description file written in just four lines. The first line says that the job universe is local and the job would
run on the submit node. The executable for the job is `/usr/bin/makeflow` with an argument `-T condor fibonacci.makeflow`. The keyword `queue` is the start button 
that submits the above three lines to the HTCondor batch system. 

Submit the local condor job, 

    $ condor_submit local_condor_makeflow.submit 
    Submitting job(s).
    1 job(s) submitted to cluster 367027.

Check the job status

    $ condor_q username -w

    -- Submitter: login01.osgconnect.net : <192.170.227.195:21720> : login01.osgconnect.net
     ID      OWNER            SUBMITTED     RUN_TIME ST PRI SIZE CMD               
    19150583.0   dbala           4/1  11:54   0+00:01:54 R  0   0.4  makeflow -T condor fibonacci.makeflow
    19150584.0   dbala           4/1  11:54   0+00:00:40 I  0   0.0  condor.sh fibonacci.bash 20 > fib.20.out
    19150585.0   dbala           4/1  11:54   0+00:00:20 I  0   0.0  condor.sh fibonacci.bash 10 > fib.10.out

The above output shows that the master is running and the two workers are waiting in the queue. The makeflow execution is a 
local condor job so it starts quickly. The two workers that run Rules 1 and 2 are distributed on OSG machines and they are waiting for resources. The jobs would complete in few minutes. 

## Summary

      Makeflow rules are based on the unix tool Make. 
      Run the master as a detached process with nohup, screen, tmux or condor local job. 
      We recommend running the master as a local condor job on the submit node. 

  
## What next?

This tutorial explains the basics of running makeflow on OSG with a toy example of generating fibonacci sequence. Check 
the examples on makeflow-R and makeflow-GROMACS that show how to run real applications on OSG with makeflow. 

## Getting Help
For assistance or questions, please email the OSG User Support team  at [user-support@opensciencegrid.org](mailto:user-support@opensciencegrid.org) or visit the [help desk and community forums](http://support.opensciencegrid.org).
