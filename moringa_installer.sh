#!/bin/bash

set -e  # Stop script on error

# Get repo root directory
ROOT_DIR=$(git rev-parse --show-toplevel) || {
    echo "Error: Not in a git repository"
    exit 1
}

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
MSG_INFO="Do not use special characters like (- / _) in the details ........... "

# Commented by Zeeshan ===============================================================
#if [ !( -d "${ROOT_DIR}/logs") ]; then
#    mkdir ${ROOT_DIR}/logs
#fi

#Added by Zeeshan ====================================================================

if [ ! -d "${ROOT_DIR}/logs" ]; then
    mkdir -p "${ROOT_DIR}/logs"
fi


# Print formatted message
log_info() {
    echo -e "${GREEN}[INFO]${NC} [$(date +'%Y-%m-%d %H:%M:%S')] $1"  | tee -a "${ROOT_DIR}/logs/${LOG_FILE}"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} [$(date +'%Y-%m-%d %H:%M:%S')] $1"  | tee -a "${ROOT_DIR}/logs/${LOG_FILE}"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} [$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "${ROOT_DIR}/logs/${LOG_FILE}"
}

# Configuration
readonly DEPLOYMENT_NAME="fe-internal-demo"
readonly ENVIRONMENT="dev"
readonly CLUSTER_NAME="${DEPLOYMENT_NAME}-${ENVIRONMENT}-gke-cluster"
readonly REGION="europe-west1"
readonly NETWORK="${DEPLOYMENT_NAME}-network"

# Database Configuration
readonly MARIADB_ROOT_PASSWORD="Moringa1234"  # Consider using secrets management
readonly SPRING_USER="springuser"
readonly SPRING_PASSWORD="Moringa1234"  # Consider using secrets management
readonly DATABASE_NAME="springboot_mariadb"
readonly PRIMARY_SERVICE="mariadb-1-mariadb"
readonly SECONDARY_SERVICE="mariadb-1-mariadb-secondary"
readonly LOG_FILE="mariadb_install_${TIMESTAMP}.log"

readonly NAMESPACE="default"
readonly DOMAIN="svc.cluster.local"

readonly ROOT_DB_DIR="${ROOT_DIR}/db"

# plugin configuration
readonly PLUGIN_DIR="${ROOT_DIR}/plugin"
readonly DB_DIR="${ROOT_DIR}/db"
readonly PLUGIN_FILE="${PLUGIN_DIR}/etnsys2.so"
readonly STORAGE_PLUGIN_CLASS="standard"
readonly PVC_PLUGIN_NAME="mariadb-plugins-pvc"
readonly PLUGIN_MOUNT_PATH="/usr/lib/mysql/plugin"

readonly DB_CNF_FILE="${ROOT_DB_DIR}/my.cnf"

#path need for this installation
readonly TOMCATSERVICE_FILE="/etc/systemd/system/tomcat.service"
readonly NGINX_SERVICE_FILE="/usr/lib/systemd/system/nginx.service"
readonly NGINX_FILE="/etc/nginx/nginx.conf"
readonly NGINX_CONFIG_FILE="/etc/nginx/conf.d/default.conf"
readonly NGINX_CACHE="/var/cache/nginx"
readonly NGINX_LOGS="/etc/nginx/logs"

#path need for this installation

# ===== Commented by Zeeshan
#MARIADB_SOURCES="/etc/apt/sources.list.d/mariadb.sources"

readonly MARIADB_SOURCES="/etc/apt/sources.list.d/mariadb.list"
readonly tomcatpath="/opt/tomcat"
readonly dbplugin="/usr/lib/mysql/plugin/"
# Request values from user with default values
echo ""
echo "==============================================================="
echo "==============================================================="
echo "========  Please provide complete App details for automatic Moringa installation and configuration =============================================================="
echo ""
echo "$MSG_INFO" 
echo ""

read -p "Application name (default: moringa): " appname
appname=${appname:-moringa}

read -p "Application prefix (default: portal): " appprefix
appprefix=${appprefix:-portal}

read -p "Currency code (default: EUR): " currency_code
currency_code=${currency_code:-EUR}

# read -p "MariaDB plugins directory (default: /usr/lib/mysql/plugin/): " dbplugin
# dbplugin=${dbplugin:-/usr/lib/mysql/plugin/}

read -p "Database user (default: portal_db_user): " dbuser
dbuser=${dbuser:-portal_db_user}

read -p "Database prefix (default: portal_db): " dbprefix
dbprefix=${dbprefix:-portal_db}

read -p "Linux user (default: moringa): " linux_user
linux_user=${linux_user:-moringa}

read -p "Semaphore prefix (default: D0): " semaprefix
semaprefix=${semaprefix:-D0}

read -p "Server IP - set the External IP in the case of a load balancer (default: 127.0.0.1) : " server_ip
server_ip=${server_ip:-127.0.0.1}

# # Check if user put a value, if not we ask again the IP of the serveur
# if [ -z "$server_ip" ]; then
#     log_warn "Server IP is mandatory."
#     read -p "Please fulfill the server IP address : " server_ip
# fi

# # If on the second request, user don't put a value we stop the script
# if [ -z "$server_ip" ]; then
#     echo "Sorry, we can't continue without a value for the server IP."
# #    exit 1
# fi
# server_ip=${server_ip}

# Displaying recovered values
echo "Selected configuration :"
echo "Application name : $appname"
echo "Application prefix : $appprefix"
echo "Currency code : $currency_code"
echo "MariaDB plugins directory : $dbplugin"
echo "Database user : $dbuser"
echo "Database prefix : $dbprefix"
echo "Linux user : $linux_user"
echo "Semaphore prefix : $semaprefix"
echo "Tomcat path: $tomcatpath"
echo "Server IP : $server_ip"

# Check if a previous installation has been run and remove the /opt/moringa directory
if [ -d "/opt/${linux_user}" ]; then
  rm -rf /opt/${linux_user}
fi

# Create necessary directories if they don't exist
mkdir /opt/${linux_user}

cd /opt/${linux_user}
mkdir bin && mkdir temp && mkdir asimina && mkdir pjt && mkdir deployment



echo ""
echo ""
echo "==============================================================="
echo "================== System update =============================="
echo "==============================================================="
echo ""

# System update
log_info "1 - System update"
apt install -y wget && apt install curl && apt install vim
apt update -y
apt upgrade -y


# Shared utility functions
check_file_exists() {
    local file="$1"
    local description="$2"
    if [ ! -f "$file" ]; then
        log_error "Error: $description file $file not found"
        return 1
    fi
    return 0
}

# Execute MariaDB command function
execute_db_command() {
    local CMD="$1"
    local DB="$2"

    #echo "Execute sql function $CMD"
    echo "Execute sql function $CMD"
    #Commented by Zeeshan
    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" "$DB" --execute="$CMD"
    #mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" --execute="$CMD"
    sleep 2s

}

# Execute local SQL function
execute_local_sql() {
    local SQL_FILE="$1"
    local DB="$2"
    local BASE_SQL_FILE=$(basename "${SQL_FILE}")

    echo "Execute sql function $SQL_FILE"

    if [ ! -f "$SQL_FILE" ]; then
        log_error "Error: SQL file $SQL_FILE not found"
        return 1
    fi

    # Execute SQL file
    echo "Executing SQL file to $DB..."
    #Commented by Zeeshan
    #mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" --execute="USE $DB;source /tmp/${BASE_SQL_FILE};"
    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" --execute="USE $DB;source ${ROOT_DIR}/db/${BASE_SQL_FILE};"
    sleep 5s
}

# Update the deploy_configs_and_plugins function
deploy_configs_and_plugins() {
    echo "Starting configurations deployment..."

    # Check required files
    check_file_exists "$DB_CNF_FILE" "MariaDB config" || return 1
    check_file_exists "$PLUGIN_FILE" "Plugin" || return 1

    # Create ConfigMaps
    echo "Creating ConfigMaps..."

    # Plugin config
    #Commentd by Zeeshan
    #cd /usr/lib/x86_64-linux-gnu/mariadb19/plugin/

    cd /usr/lib/mysql/plugin/
    cp ${ROOT_DIR}/plugin/etnsys2.so .


    # Encryption
    mkdir -p /etc/mysql/encryption
    cd /etc/mysql/encryption

    echo "1;"$(openssl rand -hex 32) > keys
    echo "2;"$(openssl rand -hex 32) >> keys
    echo "3;"$(openssl rand -hex 32) >> keys
    echo "4;"$(openssl rand -hex 32) >> keys

    openssl rand -hex 128 > password_file
    openssl enc -aes-256-cbc -md sha1 -pass file:password_file -in keys -out keys.enc

    cd /etc/mysql/
    chown -R mysql:root ./encryption
    chmod 500 /etc/mysql/encryption/

    cd ./encryption
    chmod 400 keys.enc password_file

    # MariaDB config
    cd /etc/mysql
    #Commented by Zeeshan
    # mv my.cnf my_cnf_ORIGINAL
    cp ${ROOT_DIR}/db/my.cnf .

    # Restart MariaDB
    echo ""
    echo ""
    echo "==============================================================="
    echo "========== Restarting MariaDB to apply changes ================"
    echo "==============================================================="
    echo ""

    echo "Restarting Mariadb to apply changes..."
    systemctl daemon-reload
    sleep 2s
    systemctl restart mariadb

    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" --execute="create function semwait returns integer soname 'etnsys2.so';"
    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" --execute="create function semfree returns integer soname 'etnsys2.so';"
    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" --execute="create function semadm returns integer soname 'etnsys2.so';"

    return 0

}

echo ""
echo ""
echo "==============================================================="
echo "========== MariaDB Plugins configured ========================="
echo "==============================================================="
echo ""


echo ""
echo ""
echo "==============================================================="
echo "========== Installing MariaDB ================================="
echo "==============================================================="
echo ""


# Main function
main() {
    # MariaDb installation

    #echo "Starting installation of MariaDB"
    echo "Starting installation of MariaDB"

    cd /opt
    wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
    sleep 2s
    chmod +x mariadb_repo_setup

    ./mariadb_repo_setup --mariadb-server-version="mariadb-11.5.2"

    apt install -y mariadb-server
    sleep 10s
    #echo "Starting Moringa configuration for MariaDB"
    echo "Starting Moringa configuration for MariaDB"

    # Encryption configuration & deploy etnsys2.so plugin

    #echo "Deploying config & MariaDB plugins ..."
    echo "Deploying config & MariaDB plugins ..."


    #initialize_mariadb_secondary
     if ! deploy_configs_and_plugins; then
        #echo "ERROR: Plugin deployment failed"
        echo "ERROR: Plugin deployment failed"
        exit 1
     fi
#    exit 0

    #echo "Press Enter to continue..."
    #read

    # Create user (optional)
    #echo "Creating database user ${SPRING_USER}..."
    #echo "Creating database user ${SPRING_USER}..."
    #execute_db_command "CREATE USER IF NOT EXISTS '${SPRING_USER}'@'%' IDENTIFIED BY '${SPRING_PASSWORD}';" > /dev/null
    #execute_db_command "GRANT ALL PRIVILEGES ON *.* TO '${SPRING_USER}'@'%' WITH GRANT OPTION;" > /dev/null
    #execute_db_command "FLUSH PRIVILEGES;" > /dev/null
    #sleep 1s

    # Create Local MariaDB User (This user is the same as provided at the start of the installation)
    
    #echo "Creating database user ${dbuser}..."
    echo ""
    echo "Creating database user ${dbuser}..."
    echo ""
    execute_db_command "CREATE USER IF NOT EXISTS '${dbuser}'@'localhost';" > /dev/null
    #execute_db_command "GRANT ALL PRIVILEGES ON ${dbprefix}\_%.* TO '${dbuser}'@'localhost';" > /dev/null
    execute_db_command "GRANT ALL PRIVILEGES ON \`${dbprefix}_%\`.* TO '${dbuser}'@'localhost';" > /dev/null
    execute_db_command "FLUSH PRIVILEGES;" > /dev/null
    sleep 1s


    #echo "Dropping databases..."
    echo ""
    echo "Dropping databases..."
    echo ""
    execute_db_command "DROP DATABASE IF EXISTS ${dbprefix}_catalog;"
    execute_db_command "DROP DATABASE IF EXISTS ${dbprefix}_expert_system;"
    execute_db_command "DROP DATABASE IF EXISTS ${dbprefix}_commons;"
    execute_db_command "DROP DATABASE IF EXISTS ${dbprefix}_forms;"
    execute_db_command "DROP DATABASE IF EXISTS ${dbprefix}_pages;"
    execute_db_command "DROP DATABASE IF EXISTS ${dbprefix}_portal;"
    execute_db_command "DROP DATABASE IF EXISTS ${dbprefix}_prod_catalog;"
    execute_db_command "DROP DATABASE IF EXISTS ${dbprefix}_prod_portal;"
    execute_db_command "DROP DATABASE IF EXISTS ${dbprefix}_prod_shop;"
    execute_db_command "DROP DATABASE IF EXISTS ${dbprefix}_shop;"
    execute_db_command "DROP DATABASE IF EXISTS ${dbprefix}_logger;"
    execute_db_command "DROP DATABASE IF EXISTS ${dbprefix}_sync;"

    # Create databases
    #echo "Creating required databases..."
    echo ""
    echo "Creating required databases..."
    echo ""
    execute_db_command "CREATE DATABASE IF NOT EXISTS ${dbprefix}_catalog;"
    execute_db_command "CREATE DATABASE IF NOT EXISTS ${dbprefix}_expert_system;"
    execute_db_command "CREATE DATABASE IF NOT EXISTS ${dbprefix}_commons;"
    execute_db_command "CREATE DATABASE IF NOT EXISTS ${dbprefix}_forms;"
    execute_db_command "CREATE DATABASE IF NOT EXISTS ${dbprefix}_pages;"
    execute_db_command "CREATE DATABASE IF NOT EXISTS ${dbprefix}_portal;"
    execute_db_command "CREATE DATABASE IF NOT EXISTS ${dbprefix}_prod_catalog;"
    execute_db_command "CREATE DATABASE IF NOT EXISTS ${dbprefix}_prod_portal;"
    execute_db_command "CREATE DATABASE IF NOT EXISTS ${dbprefix}_prod_shop;"
    execute_db_command "CREATE DATABASE IF NOT EXISTS ${dbprefix}_shop;"
    execute_db_command "CREATE DATABASE IF NOT EXISTS ${dbprefix}_logger;"
    execute_db_command "CREATE DATABASE IF NOT EXISTS ${dbprefix}_sync;"

    sleep 2s
    # Replace the database restoration section
    
    cd $ROOT_DIR/db/

    sed -i "s/DEFINER=[^*]*\*/\*/g" *.sql
    sed -i "s/cleandb_/${dbprefix}_/g" *.sql
    sed -i "s/asimina_/${appprefix}_/g" *.sql
    sed -i "s~/home/asimina/tomcat/~/opt/tomcat/~g" *.sql
    sed -i "s~/home/asimina/~/opt/${linux_user}/~g" *.sql

    sleep 2s

    echo ""
    echo "Restoring databases in order..."
    echo ""
    execute_local_sql "${DB_DIR}/01-cleandb_catalog.sql" "${dbprefix}_catalog"
    sleep 1s
    execute_local_sql "${DB_DIR}/02-cleandb_prod_catalog.sql" "${dbprefix}_prod_catalog"
    sleep 1s
    execute_local_sql "${DB_DIR}/03-cleandb_forms.sql" "${dbprefix}_forms"
    sleep 1s
    execute_local_sql "${DB_DIR}/04-cleandb_expert_system.sql" "${dbprefix}_expert_system"
    sleep 1s
    execute_local_sql "${DB_DIR}/05-cleandb_portal.sql" "${dbprefix}_portal"
    sleep 1s
    execute_local_sql "${DB_DIR}/06-cleandb_prod_portal.sql" "${dbprefix}_prod_portal"
    sleep 1s
    execute_local_sql "${DB_DIR}/07-cleandb_pages.sql" "${dbprefix}_pages"
    sleep 1s
    execute_local_sql "${DB_DIR}/08-cleandb_shop.sql" "${dbprefix}_shop"
    sleep 1s
    execute_local_sql "${DB_DIR}/09-cleandb_prod_shop.sql" "${dbprefix}_prod_shop"
    sleep 1s
    execute_local_sql "${DB_DIR}/10-cleandb_commons.sql" "${dbprefix}_commons"
    sleep 1s
    execute_local_sql "${DB_DIR}/11-cleandb_sync.sql" "${dbprefix}_sync"
    sleep 1s
    execute_local_sql "${DB_DIR}/12-cleandb_logger.sql" "${dbprefix}_logger"
    sleep 1s

    echo ""
    echo "==============================================================="
    echo "======= Morniga Databases created and restored succcessfully =="
    echo "==============================================================="
    echo ""
    
    echo ""
    echo "Updating Logins and Passwords... in the Databases"
    echo "" 

    # Update database : ${dbprefix}_commons
    echo "${dbprefix}_commons"
    echo ""
    execute_db_command "update config set val = substr(uuid(), 1,8) where code = 'ADMIN_PASS_SALT';" "${dbprefix}_commons"
    execute_db_command "update config set val = substr(uuid(), 1,8) where code = 'CLIENT_PASS_SALT';" "${dbprefix}_commons"
    #execute_db_command "insert currencies value ('${currency_code}');" "${dbprefix}_commons"
    execute_db_command "insert into currencies (currency_code) value ('${currency_code}');" "${dbprefix}_commons"
    sleep 2s

    # Update database : ${dbprefix}_catalog
    echo "${dbprefix}_catalog"
    echo ""
    execute_db_command "insert into person (person_id, first_name) value (1,'Admin');" "${dbprefix}_catalog"
    execute_db_command "insert into profilperson (profil_id, person_id) select profil_id, 1 from profil where profil = 'ADMIN';" "${dbprefix}_catalog"
    execute_db_command "insert into login (pid, name, puid) value (1,'admin', uuid());" "${dbprefix}_catalog"
    execute_db_command "insert into person (person_id, first_name) value (2,'SuperAdmin');" "${dbprefix}_catalog"
    execute_db_command "insert into profilperson (profil_id, person_id) select profil_id, 2 from profil where profil = 'SUPER_ADMIN';" "${dbprefix}_catalog"
    execute_db_command "insert into login (pid, name, puid) value (2,'superadmin', uuid());" "${dbprefix}_catalog"
    execute_db_command "update login set pass_expiry = date(adddate(now(), interval -1 day)), pass = sha2(concat((select val from ${dbprefix}_commons.config where code = 'ADMIN_PASS_SALT'),':','WelCome#231!',':',puid),256);" "${dbprefix}_catalog"
    sleep 2s

    # Update database : ${dbprefix}_shop
    echo "${dbprefix}_shop"
    echo ""
    execute_db_command "insert into person (person_id, first_name) value (1,'Admin');" "${dbprefix}_shop"
    execute_db_command "insert into profilperson (profil_id, person_id) select profil_id, 1 from profil where profil = 'ADMIN';" "${dbprefix}_shop"
    execute_db_command "insert into login (pid, name, puid) value (1,'admin', uuid());" "${dbprefix}_shop"
    execute_db_command "update login set pass_expiry = date(adddate(now(), interval -1 day)), pass = sha2(concat((select val from ${dbprefix}_commons.config where code = 'ADMIN_PASS_SALT'),'$','WelCome#231!','$',puid),256);" "${dbprefix}_shop"
    sleep 2s

    # Update database : ${dbprefix}_prod_shop
    echo "${dbprefix}_prod_shop"
    echo ""
    execute_db_command "insert into person (person_id, first_name) value (1,'Admin');" "${dbprefix}_prod_shop"
    execute_db_command "insert into profilperson (profil_id, person_id) select profil_id, 1 from profil where profil = 'ADMIN';" "${dbprefix}_prod_shop"
    execute_db_command "insert into login (pid, name, puid) value (1,'admin', uuid());" "${dbprefix}_prod_shop"
    execute_db_command "update login set pass_expiry = date(adddate(now(), interval -1 day)), pass = sha2(concat((select val from ${dbprefix}_commons.config where code = 'ADMIN_PASS_SALT'),'$','WelCome#231!','$',puid),256);" "${dbprefix}_prod_shop"
    sleep 2s

    # Update database : ${dbprefix}_commons
    echo "${dbprefix}_commons"
    echo ""
    execute_db_command "update config set val = '${appprefix}' where code = 'APP_PREFIX';" "${dbprefix}_commons"
    execute_db_command "update config set val = '${appname}' where code = 'APP_INSTANCE_NAME';" "${dbprefix}_commons"
    execute_db_command "update config set val = '${appname}' where code = 'APP_NAME';" "${dbprefix}_commons"
    execute_db_command "update config set val = replace(val,'/home/asimina/tomcat/','${tomcatpath}');" "${dbprefix}_commons"
    execute_db_command "update config set val = replace(val,'/home/asimina/','/opt/${linux_user}/');" "${dbprefix}_commons"
    execute_db_command "update config set val = replace(val,'/${dbprefix}_','/${appprefix}_');" "${dbprefix}_commons"
    execute_db_command "update config set val = replace(val,'cleandb_','${dbprefix}_');" "${dbprefix}_commons"
    execute_db_command "update config set val = replace(val,'D0','${semaprefix}');" "${dbprefix}_commons"
    sleep 2s

    # Update database : ${dbprefix}_catalog
    echo "${dbprefix}_catalog"
    echo ""
    execute_db_command "update config set val = replace(val,'/${dbprefix}_','/${appprefix}_');" "${dbprefix}_catalog"
    execute_db_command "update config set val = replace(val,'cleandb_','${dbprefix}_');" "${dbprefix}_catalog"
    execute_db_command "update config set val = replace(val,'D0','${semaprefix}');" "${dbprefix}_catalog"
    execute_db_command "update page set url = replace(url, '${dbprefix}_', '${appprefix}_');" "${dbprefix}_catalog"
    execute_db_command "update page_sub_urls set url = replace(url, '${dbprefix}_', '${appprefix}_');" "${dbprefix}_catalog"
    execute_db_command "update page_sub_urls set sub_url = replace(sub_url, '${dbprefix}_', '${appprefix}_');" "${dbprefix}_catalog"
    sleep 2s

    # Update database : ${dbprefix}_prod_catalog
    echo "${dbprefix}_prod_catalog"
    echo ""
    execute_db_command "update config set val = replace(val,'/home/asimina/tomcat/','${tomcatpath}');" "${dbprefix}_prod_catalog"
    execute_db_command "update config set val = replace(val,'/home/asimina/','/opt/${linux_user}/');" "${dbprefix}_prod_catalog"
    execute_db_command "update config set val = replace(val,'/${dbprefix}_','/${appprefix}_');" "${dbprefix}_prod_catalog"
    execute_db_command "update config set val = replace(val,'cleandb_','${dbprefix}_');" "${dbprefix}_prod_catalog"
    execute_db_command "update config set val = replace(val,'D0','${semaprefix}');" "${dbprefix}_prod_catalog"
    sleep 2s

    # Update database : ${dbprefix}_expert_system
    echo "${dbprefix}_expert_system"
    echo ""
    execute_db_command "update config set val = replace(val,'/home/asimina/tomcat/','${tomcatpath}');" "${dbprefix}_expert_system"
    execute_db_command "update config set val = replace(val,'/home/asimina/','/opt/${linux_user}/');" "${dbprefix}_expert_system"
    execute_db_command "update config set val = replace(val,'/${dbprefix}_','/${appprefix}_');" "${dbprefix}_expert_system"
    execute_db_command "update config set val = replace(val,'cleandb_','${dbprefix}_');" "${dbprefix}_expert_system"
    execute_db_command "update config set val = replace(val,'D0','${semaprefix}');" "${dbprefix}_expert_system"
    sleep 2s

    # Update database : ${dbprefix}_forms
    echo "${dbprefix}_forms"
    echo ""
    execute_db_command "update config set val = replace(val,'/home/asimina/tomcat/','${tomcatpath}');" "${dbprefix}_forms"
    execute_db_command "update config set val = replace(val,'/home/asimina/','/opt/${linux_user}/');" "${dbprefix}_forms"
    execute_db_command "update config set val = replace(val,'/${dbprefix}_','/${appprefix}_');" "${dbprefix}_forms"
    execute_db_command "update config set val = replace(val,'cleandb_','${dbprefix}_');" "${dbprefix}_forms"
    execute_db_command "update config set val = replace(val,'D0','${semaprefix}');" "${dbprefix}_forms"
    sleep 2s

    # Update database : ${dbprefix}_portal
    echo "${dbprefix}_portal"
    echo ""
    execute_db_command "update config set val = replace(val,'/home/asimina/tomcat/','${tomcatpath}');" "${dbprefix}_portal"
    execute_db_command "update config set val = replace(val,'/home/asimina/','/opt/${linux_user}/');" "${dbprefix}_portal"
    execute_db_command "update config set val = replace(val,'/${dbprefix}_','/${appprefix}_');" "${dbprefix}_portal"
    execute_db_command "update config set val = replace(val,'cleandb_','${dbprefix}_');" "${dbprefix}_portal"
    execute_db_command "update config set val = replace(val,'D0','${semaprefix}');" "${dbprefix}_portal"
    execute_db_command "update config set val = '${appprefix}-test-site' where code = 'basic_auth_realm';" "${dbprefix}_portal"
    sleep 2s

    # Update database : ${dbprefix}_prod_portal
    echo "${dbprefix}_prod_portal"
    echo ""
    execute_db_command "update config set val = replace(val,'/home/asimina/tomcat/','${tomcatpath}');" "${dbprefix}_prod_portal"
    execute_db_command "update config set val = replace(val,'/home/asimina/','/opt/${linux_user}/');" "${dbprefix}_prod_portal"
    execute_db_command "update config set val = replace(val,'/${dbprefix}_','/${appprefix}_');" "${dbprefix}_prod_portal"
    execute_db_command "update config set val = replace(val,'cleandb_','${dbprefix}_');" "${dbprefix}_prod_portal"
    execute_db_command "update config set val = '${appprefix}-prod-site' where code = 'basic_auth_realm';" "${dbprefix}_prod_portal"
    execute_db_command "update config set val = replace(val,'D0','${semaprefix}');" "${dbprefix}_prod_portal"
    sleep 2s

    # Update database : ${dbprefix}_pages
    echo "${dbprefix}_pages"
    echo ""
    execute_db_command "update config set val = replace(val,'/home/asimina/tomcat/','${tomcatpath}');" "${dbprefix}_pages"
    execute_db_command "update config set val = replace(val,'/home/asimina/','/opt/${linux_user}/');" "${dbprefix}_pages"
    execute_db_command "update config set val = replace(val,'/${dbprefix}_','/${appprefix}_');" "${dbprefix}_pages"
    execute_db_command "update config set val = replace(val,'cleandb_','${dbprefix}_');" "${dbprefix}_pages"
    execute_db_command "update config set val = replace(val,'D0','${semaprefix}');" "${dbprefix}_pages"
    sleep 2s

    # Update database : ${dbprefix}_shop
    echo "${dbprefix}_shop"
    echo ""
    execute_db_command "update config set val = replace(val,'/home/asimina/tomcat/','${tomcatpath}');" "${dbprefix}_shop"
    execute_db_command "update config set val = replace(val,'/home/asimina/','/opt/${linux_user}/');" "${dbprefix}_shop"
    execute_db_command "update config set val = replace(val,'/${dbprefix}_','/${appprefix}_');" "${dbprefix}_shop"
    execute_db_command "update config set val = replace(val,'cleandb_','${dbprefix}_');" "${dbprefix}_shop"
    execute_db_command "update config set val = replace(val,'D0','${semaprefix}');" "${dbprefix}_shop"
    execute_db_command "update page set url = replace(url, '${dbprefix}_', '${appprefix}_');" "${dbprefix}_shop"
    sleep 2s

    # Update database : ${dbprefix}_prod_shop
    echo "${dbprefix}_prod_shop"
    echo ""
    execute_db_command "update config set val = replace(val,'/home/asimina/tomcat/','${tomcatpath}');" "${dbprefix}_prod_shop"
    execute_db_command "update config set val = replace(val,'/home/asimina/','/opt/${linux_user}/');" "${dbprefix}_prod_shop"
    execute_db_command "update config set val = replace(val,'/${dbprefix}_','/${appprefix}_');" "${dbprefix}_prod_shop"
    execute_db_command "update config set val = replace(val,'cleandb_','${dbprefix}_');" "${dbprefix}_prod_shop"
    execute_db_command "update config set val = replace(val,'D0','${semaprefix}');" "${dbprefix}_prod_shop"
    execute_db_command "update page set url = replace(url, '${dbprefix}_', '${appprefix}_');" "${dbprefix}_prod_shop"
    sleep 2s

    # Flush hosts
    # Commented by Zeeshan
    #execute_db_command "flush-hosts"
    
    #Added by Zeeshan
    execute_db_command "FLUSH HOSTS;"

        echo "Configuration completed successfully, please reset the DB password"
}

main

echo ""
echo ""
echo "==============================================================="
echo "======= MariaDB Configuration - Completed Successfully ========"
echo "==============================================================="
echo ""


echo ""
echo ""
echo "==============================================================="
echo "======= Starting Packages Installation ========================"
echo "==============================================================="
echo ""

echo "Starting Package Installation"

installer_1(){


# ImageMagick installation
log_info "2 - ImageMagick installation"
apt install -y imagemagick
convert -version || log_warn "ImageMagick installation may have failed"

# pngquant installation
log_info "3 - Pngquant installation"
apt install -y pngquant
pngquant --version || log_warn "pngquant installation may have failed"

# MozJPEG installation
log_info "4 - MozJPEG installation"
apt install -y zlib1g-dev libpng-dev
apt-get install -y cmake autoconf automake libtool nasm make pkg-config
cd /opt

# Download MozJPEG
wget https://github.com/mozilla/mozjpeg/archive/refs/tags/v4.1.1.tar.gz -O mozjpeg.tar.gz

# Fetch expected SHA256 checksum
expected_sha512=$(curl -sL https://github.com/mozilla/mozjpeg/archive/refs/tags/v4.1.1.tar.gz | shasum -a 512 | awk '{print $1}')
# Calculate actual SHA512 checksum
actual_sha512=$(sha512sum mozjpeg.tar.gz | awk '{print $1}')

echo "expected sha512 $expected_sha512"
echo "actual sha 512 $actual_sha512"

# Compare checksums
if [ "$expected_sha512" == "$actual_sha512" ]; then
  echo "Checksum matched. Download successful."
else
  echo "SHA512 hash verification failed for mozjpeg-master.tar.gz download"
  rm mozjpeg-master.tar.gz
  exit 1
fi

tar xvzf mozjpeg.tar.gz
rm mozjpeg.tar.gz

cd mozjpeg-4.1.1/
mkdir -p build && cd build
cmake -G"Unix Makefiles" -DPNG_SUPPORTED=ON ../
sleep 1s

make install

sleep 3s
make deb
dpkg -i mozjpeg_4.1.1_amd64.deb
ln -sf /opt/mozjpeg/bin/cjpeg /usr/bin/mozjpeg
ln -sf /opt/mozjpeg/bin/jpegtran /usr/bin/mozjpegtran
mozjpeg -version || log_warn "MozJPEG installation may have failed"


echo ""
echo ""
echo "================================================================================"
echo "====== Compiling ModSecurity, Brotli and HTTP Cookie flag modules for nginx ==="
echo "================================================================================"
echo ""


# ModSecurity installation
log_info "5 - ModSecurity installation"
apt-get install -y git build-essential libpcre3 libpcre3-dev libssl-dev libtool autoconf apache2-dev libxml2-dev libcurl4-openssl-dev automake pkgconf libxslt-dev
apt-get install -y libgd-dev libgeoip-dev libxslt-dev
cd /opt
git clone -b nginx_refactoring https://github.com/SpiderLabs/ModSecurity.git
cd ModSecurity
./autogen.sh
./configure --enable-standalone-module --disable-mlogc

sleep 2s
make


# Brotli installation
log_info "6 - Brotli installation"
cd /opt
git clone https://github.com/eustas/ngx_brotli.git
cd ngx_brotli
git submodule update --init

# HTTP Cookie Flag installation
log_info "7 - HTTP Cookie Flag installation"
cd /opt
git clone https://github.com/AirisX/nginx_cookie_flag_module.git
cd nginx_cookie_flag_module/
git submodule init
git submodule update

# Tomcat installation
log_info "8 - Java 8 and Tomcat installation"

apt install -y openjdk-8-jdk openjdk-8-jre

# test if tomcat group exist
if [ ! $(getent group tomcat) ]; then
  groupadd tomcat
fi

# test if user tomcat exist
if [ ! $(getent passwd tomcat) ]; then
 useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
fi

echo ""
echo ""
echo "==============================================================="
echo "============== Tomcat Download ================================="
echo "==============================================================="
echo ""



cd /tmp

# Download Tomcat
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.102/bin/apache-tomcat-9.0.102.tar.gz -O tomcat.tar.gz
# Fetch expected SHA256 checksum
expected_sha512=$(curl -sL https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.102/bin/apache-tomcat-9.0.102.tar.gz | shasum -a 512 | awk '{print $1}')
# Calculate actual SHA512 checksum
actual_sha512=$(sha512sum tomcat.tar.gz | awk '{print $1}')

echo "expected sha512 $expected_sha512"
echo "actual sha 512 $actual_sha512"

# Compare checksums
if [ "$expected_sha512" == "$actual_sha512" ]; then
  echo "Checksum matched. Download successful."
else
  echo "SHA512 hash verification failed for apache-tomcat-9.0.102.tar.gz download"
  rm apache-tomcat-9.0.102.tar.gz
  exit 1
fi

mkdir /opt/tomcat
tar xzvf tomcat.tar.gz -C /opt/tomcat --strip-components=1

rm tomcat.tar.gz

cd /opt/tomcat
chgrp -R tomcat /opt/tomcat
chmod -R g+r conf
chmod g+x conf
chown -R tomcat webapps/ work/ temp/ logs/
# Delete every folder in webapps 
cd /opt/tomcat/webapps 
rm -rf *

sleep 3s

echo ""
echo ""
echo "==============================================================="
echo "============== Nginx Installation ============================="
echo "==============================================================="
echo ""


# Nginx installation
echo "Starting Nginx Installation"
log_info "9 - Nginx installation"
cd /opt

# Download Nginx
wget https://nginx.org/download/nginx-1.26.0.tar.gz -O nginx.tar.gz

# Fetch expected SHA256 checksum
expected_sha512=$(curl -sL https://nginx.org/download/nginx-1.26.0.tar.gz | shasum -a 512 | awk '{print $1}')
# Calculate actual SHA512 checksum
actual_sha512=$(sha512sum nginx.tar.gz | awk '{print $1}')

echo "expected sha512 $expected_sha512"
echo "actual sha 512 $actual_sha512"

# Compare checksums
if [ "$expected_sha512" == "$actual_sha512" ]; then
  echo "Checksum matched. Download successful."
else
  echo "SHA512 hash verification failed for nginx.tar.gz download"
  rm nginx.tar.gz
  exit 1
fi

tar xvf nginx.tar.gz
rm nginx.tar.gz

# Check if packages directory exists
if [ -d "${ROOT_DIR}/packages" ]; then
    cp ${ROOT_DIR}/packages/*.gz /opt/
else
    log_warn "Packages directory not found, downloading dependencies directly"
    wget https://www.openssl.org/source/openssl-3.4.0.tar.gz -O /opt/openssl-3.4.0.tar.gz
    wget https://sourceforge.net/projects/pcre/files/pcre/8.40/pcre-8.40.tar.gz -O /opt/pcre-8.40.tar.gz
    wget https://zlib.net/zlib-1.3.1.tar.gz -O /opt/zlib-1.3.1.tar.gz
fi

cd /opt
tar xvf openssl-3.4.0.tar.gz
sleep 1s
tar xvf pcre-8.40.tar.gz
sleep 1s
tar xvf zlib-1.3.1.tar.gz

rm openssl-3.4.0.tar.gz
rm pcre-8.40.tar.gz
rm zlib-1.3.1.tar.gz 

# Create nginx user group if not exists
getent group nginx || groupadd nginx
getent passwd nginx || useradd --system --home /var/cache/nginx --shell /sbin/nologin --comment "nginx user" --gid nginx nginx

# Compile and install nginx
cd /opt/nginx-1.26.0

# Commented by Zeeshan ==================================================================
#mkdir -p /usr/share/man/man8

cp man/nginx.8 /usr/share/man/man8/

./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --user=nginx --group=nginx \
            --build=Ubuntu --builddir=nginx-1.26.0 --with-select_module --with-poll_module --with-threads --with-file-aio --with-http_ssl_module \
            --with-http_v2_module --with-http_realip_module --with-http_addition_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic \
            --with-http_geoip_module=dynamic --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module \
            --with-http_gzip_static_module --with-http_auth_request_module --with-http_random_index_module --with-http_secure_link_module \
            --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --http-log-path=/var/log/nginx/access.log \
            --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-mail=dynamic --with-mail_ssl_module --with-stream=dynamic --with-stream_ssl_module \
            --with-stream_realip_module --with-stream_geoip_module=dynamic --with-stream_ssl_preread_module --with-compat --with-pcre=../pcre-8.40 \
            --with-pcre-jit --with-zlib=../zlib-1.3.1 --with-openssl=../openssl-3.4.0 --with-openssl-opt=no-nextprotoneg --with-debug \
            --add-module=/opt/nginx_cookie_flag_module --add-module=/opt/ngx_brotli

sleep 1s

echo ""
echo ""
echo "==============================================================="
echo "============== Continuing Nginx installation ..... ============"
echo "==============================================================="
echo ""

make
sleep 30s
make install

sleep 2s

#ln -s /usr/lib64/nginx/modules /etc/nginx/modules
# Added by Zeeshan === Modules directory is changed as its Old Version of Ubuntu =============================================

ln -s /usr/lib/nginx/modules /etc/nginx/modules
sleep 2s

echo ""
echo ""
echo "==============================================================="
echo "/etc/nginx/modules Symbolik Link created"
echo "==============================================================="
echo ""


# Check if NGINX is installed
#dpkg -l | grep -q nginx

#if [ $? -eq 0 ]; then
#    log_info "Nginx is installed"
#else
#    log_error "Nginx is not installed"
#fi

# Display the Nginx version installed

nginx -V

sleep 3s

# Create the file nginx.service
cat <<EOL | tee $NGINX_SERVICE_FILE
[Unit]
Description=nginx - high performance web server
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID

[Install]
WantedBy=multi-user.target
EOL
log_info "The $NGINX_SERVICE_FILE has been successfully created."

echo "Nginx Service file created"

# Comment added by Zeeshan ===================
#usermod -aG moringa nginx

# Cretae group and user
groupadd $linux_user
useradd -g $linux_user $linux_user

# Added by Zeeshan ============================
echo "Configuring  /etc/nginx Directory"

usermod -aG $linux_user nginx
chmod 750 ${tomcatpath}
cd /etc/nginx/
cp ${ROOT_DIR}/nginx_files/nginx.conf .

rm -f  *.default
mv nginx.conf nginx_conf_ORIGINAL
mkdir conf && mkdir conf.d
cp ${ROOT_DIR}/nginx_files/nginx.conf .

cd /etc/nginx/conf.d/
cp ${ROOT_DIR}/nginx_files/default.conf .

sed -i "s/<appprefix>_/${appprefix}_/g" default.conf

# Replace <server_ip> with the value of $server_ip
sed -i "s/<server_ip>/$server_ip/g" "$NGINX_CONFIG_FILE"

log_info "Nginx conf file updated with the server IP $server_ip"

# Check if Nginx cache directory exists
if [ ! -d "$NGINX_CACHE" ]; then
    log_warn "The directory $NGINX_CACHE doesn't exist. Creating this directory."
    mkdir -p "$NGINX_CACHE"

    # Check if the creation is successful
    if [ $? -eq 0 ]; then
        log_info "The directory $NGINX_CACHE has been created successfully."
    else
        log_error "Creation of the directory $NGINX_CACHE failed."
        exit 1
    fi
else
    log_info "The directory $NGINX_CACHE already exists."
fi

# Check if Nginx logs directory exists
if [ ! -d "$NGINX_LOGS" ]; then
    log_warn "The directory $NGINX_LOGS doesn't exist. Creating this directory."
    mkdir -p "$NGINX_LOGS"

    # Check if the creation is successful
    if [ $? -eq 0 ]; then
        log_info "The directory $NGINX_LOGS has been created successfully."
    else
        log_error "Creation of the directory $NGINX_LOGS failed."
        exit 1
    fi
else
    log_info "The directory $NGINX_LOGS already exists."
fi

# Check the Nginx configuration 
nginx -t

# Check the exit code of the previous command nginx -t
if [ $? -ne 0 ]; then
    log_error "The test of Nginx configuration failed, we can't continue the Moringa installation."
    exit 1
fi

log_info "Nginx configuration is OK."

# Start nginx
systemctl daemon-reload
systemctl start nginx.service
systemctl enable nginx.service
systemctl is-enabled nginx.service

echo "Nginx Installation Completed"

sleep 3s

echo ""
echo ""
echo "==============================================================="
echo "======== Nginx installed and configured successfully =========="
echo "==============================================================="
echo ""


echo ""
echo ""
echo "==============================================================="
echo "======== Starting Moringa Configuration ======================="
echo "==============================================================="
echo ""


echo "Starting Moringa Configuration"

# Moringa setup - webapp configuration
log_info "10 - Moringa setup - webapp configuration"

cd /opt/tomcat/webapps
cp -r ${ROOT_DIR}/apps/* . 

sleep 2s

# path for .asimina.cnf
ASM_CONFIG_FILE="/opt/$linux_user/.asimina.cnf"

# Configuration file creation
echo "db_host=127.0.0.1" > "$ASM_CONFIG_FILE"
echo "db_user=$dbuser" >> "$ASM_CONFIG_FILE"
echo "db_password=" >> "$ASM_CONFIG_FILE"
echo "db_prefix=$dbprefix" >> "$ASM_CONFIG_FILE"
echo "app_prefix=$appprefix" >> "$ASM_CONFIG_FILE"
echo "semaphore_prefix=$semaprefix" >> "$ASM_CONFIG_FILE"
echo "tomcat_path=/opt/tomcat" >> "$ASM_CONFIG_FILE"
echo "engines_path=/opt/$linux_user/pjt/${appprefix}_engines" >> "$ASM_CONFIG_FILE"
echo "temp_directory=/opt/$linux_user/temp" >> "$ASM_CONFIG_FILE"
echo "server_id=1" >> "$ASM_CONFIG_FILE"

# displayed generated content
echo "Created conf file : $ASM_CONFIG_FILE"
cat "$ASM_CONFIG_FILE"


# Rename all directories by replacing asimina_ by <appprefix>_ value
for dir in ${tomcatpath}/webapps/*; do
    if [ -d "$dir" ]; then
        # new_name="${appprefix}${dir#asimina_}"
        new_name="${dir/asimina/"$appprefix"}"
        mv "$dir" "$new_name"
        log_info "Directory renamed: $dir -> $new_name"
    fi
done


echo ""
echo ""
echo "==============================================================="
echo "============= Creating Sites Folders in Tomcat ================"
echo "==============================================================="
echo ""

# Create Sites Folders =============

mkdir -p /opt/tomcat/webapps/${appprefix}_portal/sites
mkdir -p /opt/tomcat/webapps/${appprefix}_prodportal/sites

chown -R tomcat:tomcat /opt/tomcat/webapps
chown -R tomcat:tomcat /opt/tomcat/webapps/${appprefix}_portal/sites
chown -R tomcat:tomcat /opt/tomcat/webapps/${appprefix}_prodportal/sites

sed "s/cleandb_/${dbprefix}_/g" -i ./${appprefix}_prodportal/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./${appprefix}_prodcatalog/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./${appprefix}_pages/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./${appprefix}_catalog/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./${appprefix}_menu/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./${appprefix}_portal/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./${appprefix}_forms/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./${appprefix}_expert_system/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./${appprefix}_shop/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./${appprefix}_prodshop/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/asimina/${dbuser}/g" -i ./${appprefix}_prodportal/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/asimina/${dbuser}/g" -i ./${appprefix}_prodcatalog/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/asimina/${dbuser}/g" -i ./${appprefix}_pages/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/asimina/${dbuser}/g" -i ./${appprefix}_catalog/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/asimina/${dbuser}/g" -i ./${appprefix}_menu/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/asimina/${dbuser}/g" -i ./${appprefix}_portal/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/asimina/${dbuser}/g" -i ./${appprefix}_forms/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/asimina/${dbuser}/g" -i ./${appprefix}_expert_system/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/asimina/${dbuser}/g" -i ./${appprefix}_shop/WEB-INF/classes/com/etn/Client/LocalSpool.conf
sed "s/asimina/${dbuser}/g" -i ./${appprefix}_prodshop/WEB-INF/classes/com/etn/Client/LocalSpool.conf

ln -s /opt/tomcat/webapps/${appprefix}_prodportal 2 >/dev/null

echo "Webapps Configuration Done ---- Tomcat needs to be restarted"

# Warning!!!!!!!!!!!  Check with Zeeshan and Umaiur : Assumption is database is on localhost running on port 3306 with no password. 
# If the database is running on another server and has a password, then you have to change the above files with that information.

# Create Tomcat Service and Start Tomcat

cat <<EOL | tee $TOMCATSERVICE_FILE
#Systemd unit file for tomcat
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre"
Environment='JAVA_OPTS=-Djava.security.egd=file:///dev/urandom'
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'

#Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/__startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
#ExecStop=/bin/kill -15 $MAINPID

UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOL

log_info "The $TOMCATSERVICE_FILE has been successfully created."


cd /opt/tomcat/bin
mv startup.sh __startup.sh
chown root:tomcat __startup.sh
chmod 750 __startup.sh

cat <<EOL | tee startup.sh
#!/bin/bash
systemctl start tomcat
EOL
chown root:tomcat startup.sh
chmod 750 startup.sh

echo Tomcat Configuration completed""
sleep 2s

# Add Nginx to the Tomcat group
usermod -aG tomcat nginx
systemctl daemon-reload
systemctl start tomcat > /dev/null
systemctl enable tomcat > /dev/null

systemctl status tomcat > /dev/null

echo ""
echo ""
echo "=================================================================="
echo "======= Webapps Configured and Deployed Successfully in Tomcat ==="
echo "=================================================================="
echo ""


echo ""
echo ""
echo "==============================================================="
echo "Moringa setup - Backend Process Configuration ================="
echo "==============================================================="
echo ""


# Moringa setup - Backend Process Configuration
log_info "11 - Moringa setup - Backend Process Configuration"
cd /opt/${linux_user}/pjt
mkdir -p ${appprefix}_engines
cd ${appprefix}_engines
cp -r ${ROOT_DIR}/engines/* . 

sed "s~/home/asimina/~/opt/${linux_user}/~g" -i ./pages/Scheduler.conf

sed "s/cleandb_/${dbprefix}_/g" -i ./catalog/com/etn/eshop/Scheduler.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./shop/com/etn/eshop/Scheduler.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./pages/Scheduler.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./prodshop/com/etn/eshop/Scheduler.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./cachesync/com/etn/eshop/Scheduler.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./portal/com/etn/eshop/Scheduler.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./forms/com/etn/eshop/Scheduler.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./selfcare/com/etn/eshop/Scheduler.conf
sed "s/cleandb_/${dbprefix}_/g" -i ./portal/com/etn/moringa/Crawler.conf
sed "s/asimina/${dbuser}/g" -i ./catalog/com/etn/eshop/Scheduler.conf
sed "s/asimina/${dbuser}/g" -i ./shop/com/etn/eshop/Scheduler.conf
sed "s/asimina/${dbuser}/g" -i ./pages/Scheduler.conf
sed "s/asimina/${dbuser}/g" -i ./prodshop/com/etn/eshop/Scheduler.conf
sed "s/asimina/${dbuser}/g" -i ./cachesync/com/etn/eshop/Scheduler.conf
sed "s/asimina/${dbuser}/g" -i ./portal/com/etn/eshop/Scheduler.conf
sed "s/asimina/${dbuser}/g" -i ./forms/com/etn/eshop/Scheduler.conf
sed "s/asimina/${dbuser}/g" -i ./selfcare/com/etn/eshop/Scheduler.conf
sed "s/asimina/${dbuser}/g" -i ./portal/com/etn/moringa/Crawler.conf


sleep 2s

sed "s/asimina_/${appprefix}_/g" -i ./catalog/sched
sed "s/asimina_/${appprefix}_/g" -i ./shop/sched
sed "s/asimina_/${appprefix}_/g" -i ./pages/sched
sed "s/asimina_/${appprefix}_/g" -i ./prodshop/sched
sed "s/asimina_/${appprefix}_/g" -i ./cachesync/sched
sed "s/asimina_/${appprefix}_/g" -i ./observer/sched
sed "s/asimina_/${appprefix}_/g" -i ./portal/sched
sed "s/asimina_/${appprefix}_/g" -i ./forms/sched
sed "s/asimina_/${appprefix}_/g" -i ./selfcare/sched

sed "s/asimina/${linux_user}/g" -i ./catalog/sched
sed "s/asimina/${linux_user}/g" -i ./shop/sched
sed "s/asimina/${linux_user}/g" -i ./pages/sched
sed "s/asimina/${linux_user}/g" -i ./prodshop/sched
sed "s/asimina/${linux_user}/g" -i ./cachesync/sched
sed "s/asimina/${linux_user}/g" -i ./observer/sched
sed "s/asimina/${linux_user}/g" -i ./portal/sched
sed "s/asimina/${linux_user}/g" -i ./forms/sched
sed "s/asimina/${linux_user}/g" -i ./selfcare/sched
sed "s/cleandb_/${dbprefix}_/g" -i ./catalog/stopsched
sed "s/cleandb_/${dbprefix}_/g" -i ./shop/stopsched
sed "s/cleandb_/${dbprefix}_/g" -i ./pages/stopsched
sed "s/cleandb_/${dbprefix}_/g" -i ./prodshop/stopsched
sed "s/cleandb_/${dbprefix}_/g" -i ./cachesync/stopsched
sed "s/cleandb_/${dbprefix}_/g" -i ./portal/stopsched
sed "s/cleandb_/${dbprefix}_/g" -i ./forms/stopsched
sed "s/cleandb_/${dbprefix}_/g" -i ./selfcare/stopsched
sed "s/D0/${semaprefix}/g" -i ./catalog/stopsched
sed "s/D0/${semaprefix}/g" -i ./shop/stopsched
sed "s/D0/${semaprefix}/g" -i ./pages/stopsched
sed "s/D0/${semaprefix}/g" -i ./prodshop/stopsched
sed "s/D0/${semaprefix}/g" -i ./cachesync/stopsched
sed "s/D0/${semaprefix}/g" -i ./portal/stopsched
sed "s/D0/${semaprefix}/g" -i ./forms/stopsched
sed "s/D0/${semaprefix}/g" -i ./selfcare/stopsched
sed "s/asimina/${dbuser}/g" -i ./catalog/stopsched
sed "s/asimina/${dbuser}/g" -i ./shop/stopsched
sed "s/asimina/${dbuser}/g" -i ./pages/stopsched
sed "s/asimina/${dbuser}/g" -i ./prodshop/stopsched
sed "s/asimina/${dbuser}/g" -i ./cachesync/stopsched
sed "s/asimina/${dbuser}/g" -i ./portal/stopsched
sed "s/asimina/${dbuser}/g" -i ./forms/stopsched
sed "s/asimina/${dbuser}/g" -i ./selfcare/stopsched
sed "s/asimina_/${appprefix}_/g" -i ./catalog/makefile
sed "s/asimina_/${appprefix}_/g" -i ./shop/makefile
sed "s/asimina_/${appprefix}_/g" -i ./pages/makefile
sed "s/asimina_/${appprefix}_/g" -i ./prodshop/makefile
sed "s/asimina_/${appprefix}_/g" -i ./cachesync/makefile
sed "s/asimina_/${appprefix}_/g" -i ./observer/makefile
sed "s/asimina_/${appprefix}_/g" -i ./portal/makefile
sed "s/asimina_/${appprefix}_/g" -i ./forms/makefile
sed "s/asimina_/${appprefix}_/g" -i ./selfcare/makefile

sleep 2s

cd /opt/${linux_user}/pjt/${appprefix}_engines/pages

sed -i "s/asimina_/${appprefix}_/g" schedPartoo
sed -i "s/asimina_/${appprefix}_/g" schedImportExport
sed "s/cleandb_/${dbprefix}_/g" -i stopschedPartoo
sed "s/asimina/${dbuser}/g" -i stopschedPartoo
sed "s/D0/${semaprefix}/g" -i stopschedPartoo
sed "s/cleandb_/${dbprefix}_/g" -i stopschedImportExport
sed "s/asimina/${dbuser}/g" -i stopschedImportExport
sed "s/D0/${semaprefix}/g" -i stopschedImportExport

cd /opt/${linux_user}/pjt/${appprefix}_engines/portal

sed "s/asimina_/${appprefix}_/g" -i minifier.sh
sed "s/asimina_/${appprefix}_/g" -i purger.sh
sed "s/asimina_/${appprefix}_/g" -i preprodcrawler.sh

sed "s~/home/asimina/~/opt/${linux_user}/~g" -i minifier.sh
sed "s~/home/asimina/~/opt/${linux_user}/~g" -i purger.sh
sed "s~/home/asimina/~/opt/${linux_user}/~g" -i preprodcrawler.sh 

# Cronjobs Configuration
#cd ${ROOT_DIR}
cd /tmp
cp /${ROOT_DIR}/crontab_list* .

sed "s/asimina_/${appprefix}_/g" -i crontab_list_first_server.txt
sed "s~/home/asimina/~/opt/${linux_user}/~g" -i crontab_list_first_server.txt

sed "s/asimina_/${appprefix}_/g" -i crontab_list_second_server.txt
sed "s~/home/asimina/~/opt/${linux_user}/~g" -i crontab_list_second_server.txt

echo "Add the cronjobs listed in the file crontab_list_first_server.txt"

echo ""
echo ""
echo "==============================================================="
echo "====== Moringa Setup - Completed Succcessfully!!!! ============"
echo "==============================================================="
echo ""

}

installer_1