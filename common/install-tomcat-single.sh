#!/bin/bash

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Set Tomcat home directory and version
tomcat_home="/apps/tomcat"
tomcat_version="10.1.7"

# Create Tomcat user
echo "Creating Tomcat user..."
if ! id -u tomcat >/dev/null 2>&1; then
    useradd --system --shell /bin/false --home-dir "${tomcat_home}" tomcat
fi

# Set Tomcat download URL and file name
tomcat_url="https://downloads.apache.org/tomcat/tomcat-10/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz"
tomcat_file="apache-tomcat-${tomcat_version}.tar.gz"

# Set initial Tomcat directory
initial_tomcat="${tomcat_home}/apache-tomcat-${tomcat_version}"
mkdir -p ${initial_tomcat}

# Download and extract Tomcat
echo "Downloading and extracting Tomcat ${tomcat_version}..."
wget -q "${tomcat_url}" -P /tmp/
tar -xzf "/tmp/${tomcat_file}" -C "${initial_tomcat}" --strip-components=1

# Create a Tomcat instance
echo "Creating a Tomcat instance..."
cp -r "${initial_tomcat}" "${tomcat_home}/instance1"

# Configure Tomcat instance
echo "Configuring Tomcat instance..."
cp "${initial_tomcat}/conf/server.xml" "${tomcat_home}/instance1/conf/server.xml.bk"
sed -i 's/8080/8081/g' "${tomcat_home}/instance1/conf/server.xml"

# Add a new web app (optional)
# if ! [ -d "${tomcat_home}/instance1/webapps/ROOT" ]; then
#     mkdir -p "${tomcat_home}/instance1/webapps/ROOT"
#     echo "<html><body><h1>New Web App</h1></body></html>" > "${tomcat_home}/instance1/webapps/ROOT/index.html"
# fi

if ! [ -f "${tomcat_home}/instance1/webapps/ROOT/test.jsp" ]; then
    cat <<'EOT' > "${tomcat_home}/instance1/webapps/ROOT/test.jsp"
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.lang.management.ManagementFactory" %>
<%@ page import="javax.management.MBeanServer" %>
<%@ page import="javax.management.ObjectName" %>
<%@ page import="org.apache.catalina.Server" %>
<%@ page import="org.apache.catalina.util.ServerInfo" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>JSP Test Page</title>
</head>
<body>
    <h1>JSP Test Page</h1>
    <p>시간: <%= new java.util.Date() %></p>
    <p>서버 이름: <%= request.getLocalName() %></p>
    <p>서버 아이피: <%= request.getServerName() %></p>
    <p>클라이언트 아이피: <%= request.getRemoteAddr() %></p>
    <%
    MBeanServer mbs = ManagementFactory.getPlatformMBeanServer();
    ObjectName name = new ObjectName("Catalina:type=Server");
    Server server = (Server) mbs.getAttribute(name, "managedResource");
    out.println("<p>인스턴스 정보: " + ServerInfo.getServerInfo() + "</p>");
    out.println("<p>인스턴스 디렉토리 경로: " + server.getCatalinaBase().getAbsolutePath() + "</p>");
    %>
    <p>인스턴스 세션 ID: <%= session.getId() %></p>
</body>
</html>
EOT
fi

# Set Tomcat permissions
echo "Setting Tomcat permissions..."
chown -R tomcat: "${tomcat_home}/instance1"
chmod +x "${tomcat_home}/instance1/bin/"*.sh

# Verify Tomcat installation
echo "Verifying Tomcat installation..."
"${tomcat_home}/instance1/bin/version.sh"

# Clean up downloaded files
rm -f /tmp/${tomcat_file}

echo "Tomcat starting..."
echo "${tomcat_home}/instance1/bin/startup.sh"