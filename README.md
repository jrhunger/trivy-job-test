# test for trivy-operator job issue
Issue ref: [509](https://github.com/aquasecurity/trivy-operator/issues/509)

## To use:
* Make sure nothing else is deployed in the default (or possibly your configured default) namespace.
* Make sure kubectl in your path and able to talk to your cluster
* Make sure trivy is installed and working

## Tuning
* May need to edit test.sh and change WAITMAX to a higher number if your cluster is slow creating the vulnerabiltyreports.

## Expected output:
```console
$ ./test.sh
cronjob.batch/job1 created
cronjob.batch/job2 created
cronjob.batch/job3 created
cronjob.batch/job4 created
cronjob.batch/job5 created
cronjob-job1-job1 cronjob-job2-job2 cronjob-job3-job3 cronjob-job4-job4 cronjob-job5-job5
cronjob.batch "job1" deleted
cronjob.batch "job2" deleted
cronjob.batch "job3" deleted
cronjob.batch "job4" deleted
cronjob.batch "job5" deleted
completed 1 iterations, last iteration elapsed = 40
...
```
Should continue like that for a while (indefinitely unless you encounter the issue)
If the issue is encountered, it will end like:
```console
60 seconds elapsed without all vulnerabilityreports being generated
suspending cronjobs
cronjob.batch/job1 patched
cronjob.batch/job2 patched
cronjob.batch/job3 patched
cronjob.batch/job4 patched
cronjob.batch/job5 patched

```
At this point you can inspect the system. First by listing the vulnerabilityreports, which will probably look something like this with one of them having two different job numbers:
```console
$ kubectl get vulnerabilityreports
NAME                REPOSITORY       TAG       SCANNER   AGE
cronjob-job1-job1   library/alpine   3.16.2    Trivy     57m
cronjob-job2-job2   library/alpine   3.15.6    Trivy     57m
cronjob-job3-job3   library/alpine   3.14.8    Trivy     57m
cronjob-job4-job4   library/alpine   3.13.12   Trivy     57m
cronjob-job5-job4   library/alpine   3.13.12   Trivy     57m
cronjob-job5-job5   library/alpine   3.15.5    Trivy     57m

```
