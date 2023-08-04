## Command to run restic backup jobs
```
kubectl get cronjobs -A --selector=restic-backup --no-headers=true | awk '{print $1 " " $2}' | xargs -n2 sh -c 'kubectl create job -n $0 --from=cronjob/$1 $1  --dry-run=client'
```

## Command to run restic restore jobs
```
kubectl get cronjobs -A --selector=restic-restore --no-headers=true | awk '{print $1 " " $2}' | xargs -n2 sh -c 'kubectl create job -n $0 --from=cronjob/$1 $1  --dry-run=client'
```