# how to break your own throwaway cluster

Please do not use this on anyone else's cluster. It's meant only for your own clusters, so most likely the ones spun up using tools like kind/minikube/etc. I'm sharing this so you can have a go at fixing a broken cluster and so that you can learn some simple bash tools/functions.

## Ingredients

1 * operational Kunbernetes cluster

1 * Rawkode application deployed to that cluster (or any application of your choice that can be upgraded and prove the cluster is operational)

1 * mechanism to copy files over to the control plane

1 * interactive terminal session (`docker exec` or `ssh`) to the control plane

## Serves

Only what you've already got running once the break is in place.

## Recipe

1. From within the repo directory, one level down from the break directory, tar the break into one file that is easy to copy over to your cluster 

```bash
tar -cvzf b.tar.gx ./break
```

2. Now copy this over to your cluster, with kind you can issue the copy command as such

```bash
docker cp ./b.tar.gz kind-control-plane:/media
```

Which should copy this over to your control plane. If you are have ssh access to your cluster then `scp` might be easier

```bash
scp b.tar.gz <user>@<node address>:/media/
```

3. Now we need to extract the tar so we can execute the break. Note this assume you copied the tar file to the `/media` directory and named it `b.tar.gz`.

```bash
cd /media

tar -xvf b.tar.gz

cd break
```

4. We are almost there, just need to make the 2 key scripts executable and then we can run the break

```bash
chmod a+x break.sh cleanup.sh
```

```bash
./break.sh
```

5. The break should be active now, if you want you can test it out before you run the final script which is a clean up to hide all of your actions from the history command (and leave a nice little present in .bash_history that Rawkode didn't find)

```bash
. /media/cleanup.sh

exit
```

The cluster should now be in the same state Rawkode [received his cluster in](https://www.youtube.com/watch?v=_BFbrrXKMOM).