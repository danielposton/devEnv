FROM ubuntu:bionic as baseos
MAINTAINER danielposton <daniel.poston@newspring.cc>
#
ENV  HUGO_VERSION=0.55.5 \
     GO_VERSION=1.12.4\
     TERRAFORM_VERSION=0.12.0-beta2    
#
WORKDIR /tmp
#
RUN  sed -i -e 's/^deb-src/#deb-src/' /etc/apt/sources.list \
     && export DEBIAN_FRONTEND=noninteractive \
     && apt-get update \
     && apt-get upgrade -y --no-install-recommends \
     && apt-get install -y --no-install-recommends \
     apt-transport-https \
     bash \
     bash-completion \
     build-essential \
     ca-certificates \
     ctags \
     curl \
     dnsutils \
     git-core \
     git \
     gnupg2 \
     htop \
     iproute2 \
     iputils-ping \
     less \
     locales \
     lynx \
     mysql-client \
     mtr \
     netcat \
     net-tools \
     nmap \
     openssh-client \
     p7zip-full \
     python \
     python-dev \
     python-pip \
     python-setuptools \ 
     software-properties-common \
     tmux \
     && locale-gen en_US.UTF-8 
#
RUN add-apt-repository ppa:neovim-ppa/unstable \
     && apt-get update && apt-get install -y \
     neovim
#
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null \
    && AZ_REPO=$(lsb_release -cs) \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    tee /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update && apt-get install -y \
    azure-cli
#
RUN curl -L https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz | tar -C /usr/local -xz \
     && curl -L https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz | tar -C /usr/local/bin -xz \
     && curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip --output terraform.zip \
     && 7z e terraform.zip \
     && cp terraform /usr/local/bin/terraform
#
RUN apt-get autoremove -y \
     && apt-get clean -y \
     && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/man /usr/share/doc   
#
RUN useradd -ms /bin/bash danielposton
#
USER danielposton
#
WORKDIR /home/danielposton
#
RUN git clone https://github.com/danielposton/dotfiles.git
#
RUN /home/danielposton/dotfiles/install.sh
#
CMD ["bash"]
