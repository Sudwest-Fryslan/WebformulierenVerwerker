FROM nexus.frankframework.org/frank-framework:7.9

# Copy Frank!
COPY --chown=tomcat configurations/ /opt/frank/configurations/
COPY --chown=tomcat tests /opt/frank/testtool/
