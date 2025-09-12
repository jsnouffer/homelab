from crossplane.function.proto.v1 import run_function_pb2 as fnv1


def compose(req: fnv1.RunFunctionRequest, rsp: fnv1.RunFunctionResponse):
    name = req.observed.composite.resource["metadata"]["name"]

    for shared_namespace in req.observed.composite.resource["spec"]["shareTemplate"]["namespaces"]:
        pv = {
            "apiVersion": "kubernetes.crossplane.io/v1alpha2",
            "kind": "Object",
            "metadata": {
                "name": f"sharedvolume-{name}-{shared_namespace}",
            },
            "spec": {
                "forProvider": {
                    "manifest": {
                        "apiVersion": "v1",
                        "kind": "PersistentVolume",
                        "metadata": {
                            "name": f"sharedvolume-{name}-{shared_namespace}",
                        },
                        "spec": {"accessModes": ["ReadWriteMany"], "persistentVolumeReclaimPolicy": "Retain"},
                    }
                },
                "providerConfigRef": {"name": "kubernetes-provider"},
                "references": [],
            },
        }

        field_paths = [
            "spec.accessModes",
            "spec.capacity",
            "spec.csi",
            "spec.storageClassName",
            "spec.volumeMode",
        ]

        for field_path in field_paths:
            pv["spec"]["references"].append(
                {
                    "patchesFrom": {
                        "apiVersion": "kubernetes.crossplane.io/v1alpha2",
                        "kind": "Object",
                        "name": f"sharedvolume-base-pv-{name}",
                        "fieldPath": f"status.atProvider.manifest.{field_path}",
                    },
                    "toFieldPath": field_path,
                }
            )

        rsp.desired.resources[f"{shared_namespace}-pv"].resource.update(pv)
        rsp.desired.resources[f"{shared_namespace}-pv"].ready = True
