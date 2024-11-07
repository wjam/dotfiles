% K9s(1) | K9s command line Documentation

# NAME

**k9s** - opens up k9s

# SYNOPSIS

| **k9s**

# DESCRIPTION

Opens up K9s, a TUI to view the state of a Kubernetes cluster.

## Pod columns

`NAME`
:    pod name

`READY`
:   number of pods in ready state / number of pods to be in ready state

`RESTARTS`
:   number of times the pod has been restarted so far

`STATUS`
:   state of the pod lifecycle, such as Running or Completed

`CPU`
:   current CPU usage in milli-vCPU

`MEM`
:   current main memory usage in MiB

`%CPU/R`
:   current CPU usage as a percentage of what has been requested by the pod

`%MEM/R`
:   current memory usage as a percentage of what has been requested by the pod

`%CPU/L`
:   current CPU usage as a percentage of the pods' limit - it cannot go before its limit

`%MEM/L`
:   current memory usage as a percentage of the pods' limit - it cannot go before its limit

`IP`
:   IP address of the pod

`NODE`
:   name of the node the pod is running on

`AGE`
:   age of the pod - units as indicated (s -> seconds, m -> minutes, h -> hours, d -> days)

## Node columns

`CPU/A`
:   amount of allocatable CPU in milli-vCPU

`MEM/A`
:   amount of allocatable memory in MiB

# SEE ALSO

`kubectl` (1).

K9s documentation site <https://k9scli.io/>.
