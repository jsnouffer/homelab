from crossplane.function.proto.v1 import run_function_pb2 as fnv1


def compose(req: fnv1.RunFunctionRequest, rsp: fnv1.RunFunctionResponse):
    name = req.observed.composite.resource["metadata"]["name"]
    for shared_namespace in req.observed.composite.resource["spec"]["sharedNamespaces"]:
        rsp.desired.resources[f"{shared_namespace}-pvc"].resource.update(
            {
                "apiVersion": "kubernetes.m.crossplane.io/v1alpha1",
                "kind": "Object",
                "metadata": {"name": f"sharedvolume-{name}", "namespace": shared_namespace},
                "spec": {
                    "forProvider": {
                        "manifest": {
                            "apiVersion": "v1",
                            "kind": "PersistentVolumeClaim",
                            "metadata": {"name": f"sharedvolume-{name}", "namespace": shared_namespace},
                            "spec": {
                                "accessModes": ["ReadWriteMany"],
                                "volumeMode": "Filesystem",
                                "resources": {"requests": {"storage": req.observed.composite.resource["spec"]["size"]}},
                                "storageClassName": req.observed.composite.resource["spec"]["storageClassName"],
                                "volumeName": f"sharedvolume-{name}-{shared_namespace}"
                            },
                        }
                    },
                    "providerConfigRef": {"kind": "ClusterProviderConfig", "name": "kubernetes-provider"},
                },
            }
        )
        rsp.desired.resources[f"{shared_namespace}-pvc"].ready = True
