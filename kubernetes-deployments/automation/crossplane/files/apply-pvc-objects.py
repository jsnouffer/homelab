from crossplane.function.proto.v1 import run_function_pb2 as fnv1
from google.protobuf.json_format import MessageToDict


def compose(req: fnv1.RunFunctionRequest, rsp: fnv1.RunFunctionResponse):
    name = req.observed.composite.resource["metadata"]["name"]
    labels_struct = req.observed.composite.resource["spec"]["shareTemplate"].fields.get("labels")
    labels = {}
    if labels_struct:
        labels = MessageToDict(labels_struct)
    annotations_struct = req.observed.composite.resource["spec"]["shareTemplate"].fields.get("annotations")
    annotations = {}
    if annotations_struct:
        annotations = MessageToDict(annotations_struct)
    for shared_namespace in req.observed.composite.resource["spec"]["shareTemplate"]["namespaces"]:
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
                            "metadata": {
                                "name": f"sharedvolume-{name}",
                                "namespace": shared_namespace,
                                "labels": labels,
                                "annotations": annotations,
                            },
                            "spec": {
                                "accessModes": ["ReadWriteMany"],
                                "volumeMode": "Filesystem",
                                "resources": {
                                    "requests": {
                                        "storage": req.observed.composite.resource["spec"]["storageTemplate"]["size"]
                                    }
                                },
                                "storageClassName": req.observed.composite.resource["spec"]["storageTemplate"][
                                    "storageClassName"
                                ],
                                "volumeName": f"sharedvolume-{name}-{shared_namespace}",
                            },
                        }
                    },
                    "providerConfigRef": {"kind": "ClusterProviderConfig", "name": "kubernetes-provider"},
                },
            }
        )
        rsp.desired.resources[f"{shared_namespace}-pvc"].ready = True
