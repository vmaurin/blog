FROM python:latest

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN if getent group ${GROUP_ID}; then groupdel -f $(getent group ${GROUP_ID} | cut -d ':' -f 1); fi &&\
    groupadd -g ${GROUP_ID} developer &&\
    if getent passwd ${USER_ID}; then userdel -f $(getent passwd ${USER_ID} | cut -d ':' -f 1); fi &&\
    useradd -l -m -u ${USER_ID} -g ${GROUP_ID} developer

COPY requirements.txt /opt/
RUN pip install -r /opt/requirements.txt

USER developer

