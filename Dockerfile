FROM nexus.frankframework.org/frank-framework:7.8

# Copy Frank!
COPY --chown=tomcat configurations/ /opt/frank/configurations/
COPY --chown=tomcat tests/ /opt/frank/testtool/
COPY --chown=tomcat classes/ /opt/frank/resources/
COPY --chown=tomcat context.xml /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml

# Martijn May 2 2023: Copied from ZaakBrug and edited in a trivial way.
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 \
  CMD curl --fail --silent http://localhost/iaf/api/server/health || (curl --silent http://localhost/iaf/api/server/health && exit 1)