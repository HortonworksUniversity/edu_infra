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

# Labels
LABEL maintainer="William Dailey <wdailey@cloudera.com>"
LABEL org.label-schema.description="PostgreSQL RDBMS to support applications"
LABEL org.label-schema.version="PostgreSQL v10"

# Variables

# Install PostgreSQL 10 
# Uncomment if building standalone
# RUN yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm && \
RUN	yum install -y postgresql10 postgresql10-server && \
	yum update -y && yum clean all 

# Create a link to correct 
RUN ln -s /var/lib/pgsql/10/data /var/lib/pgsql/data

# Configure init scripts
COPY init/postgresql-init.service /lib/systemd/system
COPY init/postgresql-db.service /lib/systemd/system
RUN systemctl enable postgresql-init.service && \
	systemctl enable postgresql-db.service && \
	systemctl enable postgresql-10.service

# Configure RDBMS scripts
RUN mkdir /usr/local/conf
COPY conf/ /usr/local/conf/
COPY sbin/ /usr/local/sbin/ 
RUN /usr/local/sbin/fix-permissions.sh /var/lib/pgsql && \
    /usr/local/sbin/fix-permissions.sh /var/run/postgresql

# Set path for scripts rather than hard-code them in scripts
ENV PGDATA=/var/lib/pgsql/10/data
