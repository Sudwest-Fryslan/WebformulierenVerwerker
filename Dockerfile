# Keep in sync with version in frank-runner.properties
# Check whether java-orig files present and have changed in F!F and update custom code (java and java-orig files) accordingly
FROM frankframework/frankframework:8.1.0-20240404.042328


# Copy dependencies
# COPY --chown=tomcat lib/server/ /usr/local/tomcat/lib/
# COPY --chown=tomcat lib/webapp/ /usr/local/tomcat/webapps/ROOT/WEB-INF/lib/

# Compile custom class, this should be changed to a buildstep in the future 
# COPY --chown=tomcat java /tmp/java
# RUN javac \
#       /tmp/java/nl/nn/adapterframework/http/HttpSenderBase.java \
#       /tmp/java/nl/nn/adapterframework/http/HttpSessionBase.java \
#       -classpath "/usr/local/tomcat/webapps/ROOT/WEB-INF/lib/*:/usr/local/tomcat/lib/*" \
#       -verbose -d /usr/local/tomcat/webapps/ROOT/WEB-INF/classes
# RUN rm -rf /tmp/java

# Copy database connection settings
COPY --chown=tomcat context.xml /usr/local/tomcat/conf/Catalina/localhost/ROOT.xml

# Copy Frank!
COPY --chown=tomcat configurations/ /opt/frank/configurations/
COPY --chown=tomcat tests/ /opt/frank/testtool/
COPY --chown=tomcat classes/ /opt/frank/resources/

# Martijn May 2 2023: Copied from ZaakBrug and edited in a trivial way.
HEALTHCHECK --interval=15s --timeout=5s --start-period=30s --retries=3 \
      CMD curl --fail --silent http://localhost:8080/iaf/api/server/health || (curl --silent http://localhost:8080/iaf/api/server/health && exit 1)
