#  Copyright (C) 2018-2020 LEIDOS.
# 
#  Licensed under the Apache License, Version 2.0 (the "License"); you may not
#  use this file except in compliance with the License. You may obtain a copy of
#  the License at
# 
#  http://www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#  License for the specific language governing permissions and limitations under
#  the License.

FROM usdotfhwastol/autoware.ai:3.5.0 as deps

# Install remaining package deps
RUN mkdir ~/src
COPY --chown=carma . /home/carma/src/
RUN rm -R /home/carma/src/

FROM deps as setup

RUN mkdir ~/src
COPY --chown=carma . /home/carma/src/
RUN ~/src/docker/checkout.sh
RUN ~/src/docker/install.sh

FROM deps

ARG BUILD_DATE="NULL"
ARG VERSION="NULL"
ARG VCS_REF="NULL"

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="carma-ssc-interface-wrapper-driver"
LABEL org.label-schema.description="ssc interface wrapper driver for the CARMA Platform"
LABEL org.label-schema.vendor="Leidos"
LABEL org.label-schema.version=${VERSION}
LABEL org.label-schema.url="https://highways.dot.gov/research/research-programs/operations/CARMA"
LABEL org.label-schema.vcs-url="https://github.com/usdot-fhwa-stol/CARMASscInterfaceWrapper/"
LABEL org.label-schema.vcs-ref=${VCS_REF}
LABEL org.label-schema.build-date=${BUILD_DATE}

COPY --from=setup /home/carma/install /opt/carma/install
RUN sudo git clone https://github.com/NewEagleRaptor/pacifica-dbw-ros.git /opt/pacifica-dbw-ros --branch master --depth 1 && sudo cp /opt/pacifica-dbw-ros/dbw_pacifica_can/New_Eagle_DBW_3.3.388.dbc /opt/carma/install/share/dbw_pacifica_can/New_Eagle_DBW_3.3.388.dbc && sudo rm -rf /opt/pacifica-dbw-ros

CMD [ "wait-for-it.sh", "localhost:11311", "--", "roslaunch", "ssc_interface_wrapper", "ssc_interface_wrapper.launch"]
