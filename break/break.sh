#!/bin/bash

# Run me on the control plane node

# --------------
# Prep the hints
# --------------
mv /media/break/hints /root/

# ------------
# Cryptogrpahy 
# ------------
echo "Cryptography pt1"

# create a directory where kubelet will actually be looking
mkdir -p /etc/qube/manifests

# copy files for kubelet to really watch
cp /etc/kubernetes/manifests/etcd.yaml                    /etc/qube/manifests/
cp /etc/kubernetes/manifests/kube-controller-manager.yaml /etc/qube/manifests/
cp /etc/kubernetes/manifests/kube-scheduler.yaml          /etc/qube/manifests/
cp /etc/kubernetes/manifests/kube-vip.yaml                /etc/qube/manifests/
cp /etc/kubernetes/manifests/kube-apiserver.yaml          /etc/qube/manifests/

# edit kubelet to use qube directory
sed -i -e 's/\/etc\/kubernetes\/manifests/\/etc\/qube\/manifests/g' /var/lib/kubelet/config.yaml

# restart to pickup new folder, therefore any edits to files in there will cause refresh and thus bring api server down .
systemctl restart kubelet
kubectl -n kube-system delete pod -l component=kube-apiserver

# now we can break the api server
sed -i -e 's/k8s.gcr.io\/kube-apiserver/k8s.gcr.io\/kube-scheduler/g' /etc/qube/manifests/kube-apiserver.yaml


# ------
# Forest 
# ------
echo "Forest"

# create a fake directory that looks like the static manifest 
mkdir /etc/kubernetes/zmanifestz

# copy into usual manifests diectory
mv /etc/kubernetes/manifests/kube-apiserver.yaml          /etc/kubernetes/manifests/a.yaml
mv /etc/kubernetes/manifests/etcd.yaml                    /etc/kubernetes/manifests/b.yaml
mv /etc/kubernetes/manifests/kube-controller-manager.yaml /etc/kubernetes/manifests/c.yaml
mv /etc/kubernetes/manifests/kube-scheduler.yaml          /etc/kubernetes/manifests/d.yaml
mv /etc/kubernetes/manifests/kube-vip.yaml                /etc/kubernetes/manifests/e.yaml

# fake break (which is actually also real)
sed -i -e 's/6443/6433/g' /etc/kubernetes/manifests/a.yaml


# copy decoy files into zmanifestz
seed="aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbccccccccccccccccccccccccccccccccccccccccccccccccccddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"
for i in {1..50}
do
    # need to create multiple, would like something like a.yaml to aaaaaaaaa.yaml
    cp /etc/kubernetes/manifests/a.yaml /etc/kubernetes/zmanifestz/${seed:0:i}.yaml
    cp /etc/kubernetes/manifests/b.yaml /etc/kubernetes/zmanifestz/${seed:50:i}.yaml
    cp /etc/kubernetes/manifests/c.yaml /etc/kubernetes/zmanifestz/${seed:100:i}.yaml
    cp /etc/kubernetes/manifests/d.yaml /etc/kubernetes/zmanifestz/${seed:150:i}.yaml
    cp /etc/kubernetes/manifests/e.yaml /etc/kubernetes/zmanifestz/${seed:200:i}.yaml
done

# setup alias injection
cp /media/break/.bashrc       /root/.bashrc
cp /media/break/bash.bashrc   /etc/bash.bashrc
cp /media/break/.bash_aliases /root/.bash_aliases
cp /media/break/.profile      /root/.profile
cp /media/break/ali           /etc/.profile
cp /media/break/ali           /usr/share/bash-completion/bash_completion
cp /media/break/set.txt       /var/lib/dpkg/set
mv /media/b.tar.gz            /var/lib/dpkg
mv /media/break/cleanup.sh    /media/


echo "Cryptography pt2"

# this is technically part of Crptography, but it needs to run at the end
sed -i -e 's/6443/6433/g' /etc/qube/manifests/kube-apiserver.yaml

# ----------
# Industrial
# ----------
echo "Industrial"

# alter DNS server
sed -i -e 's/10.96.0.10/10.96.0.1/g' /var/lib/kubelet/config.yaml

echo "Kubelet restart incoming"

# restart kubelet (anything new from now on is going to have DNS issues)
systemctl restart kubelet
kubectl -n kube-system delete pod -l component=kube-apiserver

echo "Beach"

# break anything based on sh (as sh is a link to dash on Ubuntu)
# this does break it but if teh server restarts it won't come back up on it's own ... bit to big of a break.
#mv /usr/bin/dash  /usr/bin/dash.klustered

# milder break hopefully plus also klustered machines didn't have preexecstart 
# subtly alter the path to the kubeletin systemd config 
sed -i -e 's/\/usr\/bin\/kubelet/\/etc\/kubelet/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf


echo "Kubelet going to sleep"
# stop kubelet again (kubelet isn't starting again after this)
systemctl stop kubelet

echo "Done - remember to run . ./cleanup.sh"