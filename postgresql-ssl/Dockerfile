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

FROM wmdailey/postgresql:latest

# Labels
LABEL maintainer="William Dailey <wdailey@cloudera.com>"
LABEL org.label-schema.description="PostgreSQL RDBMS with SSL"
LABEL org.label-schema.version="PostgreSQL v10"

# Variables

# Configure SSL
COPY conf/postgresql.conf /usr/local/conf/
RUN mkdir /usr/local/pki
COPY pki /usr/local/pki

# Configure create Keycloak db 
COPY sbin/setup-keycloak.sh /usr/local/sbin/
COPY init/postgresql-keycloak.service /lib/systemd/system
RUN systemctl enable postgresql-keycloak.service
