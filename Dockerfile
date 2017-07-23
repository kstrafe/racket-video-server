from fedora:26

run dnf update -y && dnf upgrade -y
run dnf install -y \
	findutils \
	libedit-devel \
	gcc \
	git \
	gpg \
	pass \
	passwd \
	sqlite \
	sudo \
	tmux \
	vim \
	youtube-dl

run dnf -y install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-24.noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-24.noarch.rpm && dnf clean all && dnf -y install ffmpeg

run dnf -y install procps-ng

run groupadd -r sudo
run curl -sSf https://mirror.racket-lang.org/installers/6.9/racket-6.9-x86_64-linux.sh > racket && sh racket <<< $(printf 'yes\n1\n\n')

run dnf install -y openssl-devel
run adduser user
run mkdir -p /home/user
user user

run raco pkg install reloadable
user root
run userdel user

volume [ "/home/user/stuf" ]
workdir "/home/user/stuf"

cmd ["bash", "-c", "adduser --no-create-home user -u \"$HOST_UID\" && passwd user <<< $(printf \"$HOST_PASS\\n$HOST_PASS\\n\") && chown user: /home/user && su - user <<< 'cd stuf && ./main.rkt'"]
