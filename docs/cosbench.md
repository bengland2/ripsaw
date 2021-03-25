# COSBench Benchmark

[COSBench](https://github.com/intel-cloud/cosbench) is a Java-based distributed S3 object storage workload generator which can be used to quickly measure performance for a variety of object storage workloads across an entire cluster.  To be clear, "object storage"
here means that the I/O is submitted via the HTTP protocol not through any POSIX API.   Specifically, this implementation
of the COSBench benchmark is meant to just containerize it and make it into an Kubernetes-friendly workload, not to change
how it works.

## Running COSBench Benchmark using Ripsaw
Once the operator has been installed following the instructions, you have to specify the COSBench workload using
the YAML CR file.  Since COSBench has a rich set of input parameters, this may not be trivial to do. It assumes that you
have set up the S3 endpoint already.

TBS

```yaml
apiVersion: ripsaw.cloudbulldozer.io/v1alpha1
kind: Benchmark
metadata:
  name: example-benchmark
  namespace: my-ripsaw
spec:
  workload:
    name: COSBench
    args:
      clients: 2
      workload_sequence: 
      threads: 5
      object_size_kb: 64
      objects: 100
      s3_URL: https://my-test-cluster.com:8080/cosbench
```

The COSBench benchmark also gives the leverage to run multiple test operations in a user-defined sequence. 
An example is in the [Custom Resource Definition file](../resources/crds/ripsaw_v1alpha1_cosbench_cr.yaml).

## Adding More options in smallfile tests

COSBench also comes with a variety of configurable options for running tests, 
following are the parameters that can be added to CR file in workload arguments:

 * **parameter_1** – TBS
 * **parameter_2** – TBS

Once done creating/editing the resource file, one can run it by:

```bash
# kubectl apply -f resources/your_cosbench_cr.yaml
```

Deploying the above(assuming clients set to 1) would result in
```bash
$ kubectl get pods
NAME                                                   READY     STATUS    RESTARTS   AGE
benchmark-operator-7c6bc98b8c-2j5x5                    2/2       Running   0          47s
example-benchmark-cosbench-client-1-benchmark-hwj4b   1/1       Running   0          33s
```

To see the output of the run one has to run `kubectl logs <client>`. This is shown below:
```bash
$ kubectl logs example-benchmark-cosbench-client-1-hwj4b
TBS
```
