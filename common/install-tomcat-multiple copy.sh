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

# Array to store used ports
used_ports=()

# Loop to create Tomcat instances
echo "Creating Tomcat instances..."
echo "Creating Tomcat instances..."
for i in {1..3}; do
    # Set Tomcat instance directory and port
    instance_dir="${tomcat_home}/instance${i}"
    http_port=$(( 18080 + (i - 1) * 100 ))
    shutdown_port=$(( http_port - 75 ))
    ajp_port=$(( http_port + 1 ))
    https_port=$(( http_port + 443 ))

    # Check if the port is already in use
    if lsof -Pi :$http_port -sTCP:LISTEN -t >/dev/null; then
        echo "Port ${http_port} is already in use. Exiting."
        exit 1
    fi

    # Create Tomcat instance
    cp -r "${initial_tomcat}" "${instance_dir}"

    # Configure Tomcat instance
    echo "Configuring Tomcat instance ${i}..."
    cp "${initial_tomcat}/conf/server.xml" "${instance_dir}/conf/server.xml.bk"
    sed -i "s/8080/${http_port}/g" "${instance_dir}/conf/server.xml"
    sed -i "s/8005/${shutdown_port}/g" "${instance_dir}/conf/server.xml"
    sed -i "s/8009/${ajp_port}/g" "${instance_dir}/conf/server.xml"
    sed -i "s/8443/${https_port}/g" "${instance_dir}/conf/server.xml"

    # Set Tomcat permissions
    echo "Setting Tomcat permissions..."
    chown -R tomcat: "${instance_dir}"
    chmod +x "${instance_dir}/bin/"*.sh

    # Verify Tomcat installation
    echo "Verifying Tomcat installation..."
    "${instance_dir}/bin/version.sh"

    # Start Tomcat instance
    echo "Starting Tomcat instance ${i}..."
    "${instance_dir}/bin/startup.sh"

done

# Clean up
rm -f /tmp/${tomcat_file}

echo "Tomcat instances created successfully."


