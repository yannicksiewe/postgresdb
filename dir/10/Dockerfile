FROM centos/postgresql-10-centos7:latest

USER 0

#--------------------------------------------------------------------
# clean and fix directory permission for openshift && kubernetes
#--------------------------------------------------------------------
RUN yum upgrade -y \
  && yum clean all \
  && yum -y clean all --enablerepo='*' \
  && /usr/libexec/fix-permissions /var/lib/pgsql /var/run/postgresql

#--------------------------------------------------------------------
# Install awscli using pip
#--------------------------------------------------------------------
RUN yum update && \
    yum install -y \
        python3 \
        python3-pip \
        python3-setuptools \
        groff \
        less \
    && pip3 install --upgrade pip \
    && yum clean all

RUN pip3 --no-cache-dir install --upgrade awscli

# https://github.com/sclorg/postgresql-container/blob/384c2584537836d99129ba36dc5f25345212b60d/10/Dockerfile#L86
USER 26

COPY "root/${APP_DATA}/src/postgresql-start" "${APP_DATA}/src/postgresql-start"
