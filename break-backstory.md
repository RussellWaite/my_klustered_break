# You did what?

Warning, spoilers. If you are going to run this on your own kind cluster then leave this page before you see all the trickery.

As I'm not a techie by trade anymore, I set aside all hte more complex breaks I could imagine but 

### Beach

This one was going to be an attack of the `sh` shell, well, just the `sh` link to the underlying dash implementation. So my naming came from "where else do you find shells?".

I had to give up on this though when I tested what would happen if the server rebooted... The server does not come back online. Thankfully I used kind clusters so I just needed to delete and spin back up a new set of nodes in docker. Testing for the win! There was another issue which was my kind nodes and the Klustered nodes were not identical and ExecStartPre was not set for the `kubelet` service.

A quick pivot (whilst forgetting to rename the zone) and I got the same broken `kubelet` but without the risk of rendering the control plane node useless. 

So this attack is a change to the systemd config for `kubelet`, altering the path to the `kubelet` from `/usr/bin/kubelet` to `/etc/kubelet` (which is a file, but it's a text file containing config). Side note, kubelet appears to be installed into `/usr/bin` and `/bin` as my first attempt at this attack failed when `kubelet` successfully started even though I had deleted `/usr` from it's ExecStart parameter.

So, once this change is made and the `kubelet` is stopped, it's not starting back up until that's put back. `kubelet` is the key to running any of the kube-system pods declared in the static manifest location on the control plane, so once kubelet stops kubernetes is stuck with whatever is already running. 


### Forest

This is all about misdirection, slowing people down and installing doubt in their minds.

From what I've witnessed of Rawkode, he typically does 4 things straight away, exports `KUBECONFIG`, aliases `k` to be `kubectl`, runs something like `k get pods` and then if there was an issue with a core kubernetes component, `cd`s into `/etc/kubernetes/manifests to have a look at the static manifests.



I just talked about the static manifest location used by kubelet to make any changes to the control plane's static components like the api server, controller manager, scheduler, etcd and on a Klustered cluster the Kube-VIP virtual IP/load balancer 

> note to self, I need to look into this more and compare it to metallb that I use in kind.

Typically it is located at `/etc/kubernetes/manifests` however it is configurable in `kubelet`'s `/var/lib/kubelet/config.yaml` file. Now, the Forest zone is the one I had the most evil fun with and so it's got more layers to it.

#### Layer 1

Within the "manifests" folder were 250 YAML files, 50 copies of each real static manifest but with the API server broken and all files renamed to be unique but not descriptive (and yes, I scripted this). The challenge was to work out how there could be 50 replicas of each file (I assume that would throw out a lot of errors). My hope was to make him start using the hints.

#### Layer 2

This was where he was meant to have the "aha" moment and see that I'd conned him to look at `/etc/kubernetes/zmanifestz` (using z to prevent tab completion iterating over it is he was in `/etc/kubernetes/` and typed m then tab). The bash_aliases were meant to be discovered and lead him to remove them somehow and then go look in the real `/etc/kubernetes/manifests` folder that had only 5 YAML files, with the API server "broken".

#### Layer 3

This was the point where I wanted him to have "fixed" the "real" manifests, only to discover it had no effect. To implant doubt in his mind about how simple the breaks were.

#### Layer 4

The hope here was that Rawkode would have used `cat` to read out the contents of the `/var/lib/kubelet/config.yaml` file in the previous step. `cat` was aliased to replace the real directory `/etc/qube/manifests`  with what he thought was the real one `/etc/kubernetes/manifests`

### Cryptography

I teased that I had dumped the ciphers from the control plane, but this one is quite simple and quick to fix (as long as you are editing the right files). I just altered the port that the API server was listening on. Layering simple breaks can be just as difficult to solve as one complex one.

### Industrial

Its always DNS, and that is true for this, I couldn't leave without breaking DNS somehow. 

However, I didn't. Poor testing on my part didn't account for this just working. It's a shame as this is one of the mechanisms I wanted to show people as I had discovered it during this little project. The mighty `PROMPT_COMMAND`.

Here is what it was supposed to do:

The following `sed` command makes the change against the in-place file, so there is no need to copy over a pre-changed file or edit it in vim and then forget to move the cursor thus giving Rawkode a nice big hint when he opens the file:

`sed -i -e 's/10.96.0.10/10.96.0.1/g' /var/lib/kubelet/config.yaml`

The magic of `PROMPT_COMMAND` is that it runs every single time the user enters a command, it's like a cron job that fires whenever a user does something in a shell. So I was hoping that every time Rawkode fixed the DNS IP address, he would also initiate the break again.

In hindsight I wish I had used a `kubectl apply -f` and used Rawkode's deployment spec with the v1 version of the app which should have messed with his head just a little bit more... maybe next time.
