# Hortonworks University
# This Dockerfile is for training purposes only and is to be used only
# in support of approved Hortonworks University images. Hortonworks
# assumes no liability for use outside of our training environments.
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This image must forever use UID 26 for postgres user so our volumes are
# safe in the future. This should *never* change, the last test is there
# to make sure of that.

FROM wmdailey/security:latest
MAINTAINER WKD

ENV SUMMARY="PostgreSQL supporting a HDP or HDF cluster" 

LABEL summary="$SUMMARY" \
      name="centos/postgresql-10-centos7" \
      version="10" 

# Pull in rpm for 9.6
# RUN rpm -Uvh http://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
# Pull in rpm for 10 
RUN yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

# Install
RUN yum install -y postgresql10 postgresql10-server
RUN yum clean all && \
    localedef -f UTF-8 -i en_US en_US.UTF-8 

# Set path for scripts rather than hard-code them in scripts
#ENV PGDATA=/var/lib/pgsql/9.6/data
ENV PGDATA=/var/lib/pgsql/10/data

# Copy in usr file system and admin scripts
RUN mkdir /usr/local/conf
COPY conf/ /usr/local/conf/
COPY sbin/ /usr/local/sbin/ 
RUN  test "$(id postgres)" = "uid=26(postgres) gid=26(postgres) groups=26(postgres)" 
RUN /usr/local/sbin/fix-permissions.sh /var/lib/pgsql && \
    /usr/local/sbin/fix-permissions.sh /var/run/postgresql

# Copy in init scripts
COPY init/postgresql-init.service /lib/systemd/system
COPY init/postgresql-db.service /lib/systemd/system
RUN systemctl enable postgresql-init.service
RUN systemctl enable postgresql-db.service
RUN systemctl enable postgresql-10.service
