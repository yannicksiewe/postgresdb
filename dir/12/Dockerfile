FROM centos/postgresql-12-centos7:latest

USER 0

ENV PG_MAJOR 12
ENV POSTGIS_MAJOR 3
ENV POSTGIS_VERSION 3.1.1+dfsg-1.pgdg100+1

#--------------------------------------------------------------------
# clean and fix directory permission for openshift && kubernetes
#--------------------------------------------------------------------
# https://github.com/sclorg/postgresql-container/issues/369
RUN rm -f /etc/yum.repos.d/cbs.centos.org_repos_sclo7-rh-postgresql12-rh-candidate_x86_64_os_.repo \
  && yum upgrade -y \
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

RUN yum update \
      && yum -y install epel-release \
      && yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
      && yum install -y yum install postgis25_12 --skip-broken\
      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d

# https://github.com/sclorg/postgresql-container/blob/384c2584537836d99129ba36dc5f25345212b60d/10/Dockerfile#L86
USER 26

COPY "root/${APP_DATA}/src/postgresql-start" "${APP_DATA}/src/postgresql-start"
COPY "root/${APP_DATA}/src/postgresql-start/initdb-postgis.sh" /docker-entrypoint-initdb.d/10_postgis.sh
COPY "root/${APP_DATA}/src/postgresql-start/update-postgis.sh" /usr/local/bin