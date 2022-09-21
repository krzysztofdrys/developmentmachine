FROM ubuntu:22.10
ARG USERNAME=platanus
ARG KUBECTL_VERSION=v1.18.2
# curl -Ls https://api.github.com/repos/Versent/saml2aws/releases/latest | grep 'tag_name' | cut -d'v' -f2 | cut -d'"' -f1
ARG SAML2AWS_VERSION=2.35.0
ARG GO_VERSION=1.18.2
ARG K9S_VERSION=v0.25.18

# Install packages
RUN apt-get update && apt-get install -y \
    build-essential \
    curl  \
    dnsutils \
    file \
    git \
    groff \
    jq \
    less \
    openssl \
    procps  \
    ripgrep \
    sudo \
    vim \
    wget \
    zip \
    zsh \
 && rm -rf /var/lib/apt/lists/*

# Add user
RUN useradd -rm -d /home/$USERNAME -s /bin/bash -g root -G sudo -u 1001 $USERNAME
ENV USER $USERNAME
ENV HOME /home/$USERNAME

# kubectl
RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN sudo ./aws/install
RUN sh -c "$(curl -fsSL https://starship.rs/install.sh )" "" --yes

# go
RUN curl -OL https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
RUN tar -C /usr/local -xvf go${GO_VERSION}.linux-amd64.tar.gz

USER $USERNAME:root
RUN mkdir -p /home/$USERNAME/bin

# shell
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# saml2aws
RUN wget -c https://github.com/Versent/saml2aws/releases/download/v${SAML2AWS_VERSION}/saml2aws_${SAML2AWS_VERSION}_linux_amd64.tar.gz -O - | tar -xzv -C ~/bin
RUN chmod u+x ~/bin/saml2aws

# k9s
RUN wget -c https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_arm64.tar.gz -O - | tar -xzv -C ~/bin
RUN chmod u+x ~/bin/k9s


WORKDIR /home/$USERNAME
COPY .zshrc /home/$USERNAME/.zshrc