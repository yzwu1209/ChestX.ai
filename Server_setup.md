# ChestX.ai Server Setup

## 1. Mount object storage to IBM Cloud virtual server
- Reference: https://github.com/MIDS-scaling-up/v2/tree/master/week02/lab2

```
# install s3fs-fuse package
sudo apt-get update
sudo apt-get install automake autotools-dev g++ git libcurl4-openssl-dev libfuse-dev libssl-dev libxml2-dev make pkg-config
git clone https://github.com/s3fs-fuse/s3fs-fuse.git

# Build and install the library
cd s3fs-fuse
./autogen.sh
./configure
make
sudo make install

# Configure s3fs-fuse
# Please contact ChestX.ai team for Access_Key_ID and Secret_Access_Key
echo "Access_Key_ID:Secret_Access_Key" > $HOME/.cos_creds
chmod 600 $HOME/.cos_creds

sudo mkdir -m 777 /mnt/storage_chestxai/
sudo s3fs <bucket: please contact ChestX.ai team> /mnt/storage_chestxai/ -o passwd_file=$HOME/.cos_creds -o sigv2 -o use_path_request_style -o url=https://s3.us-east.cloud-object-storage.appdomain.cloud
```

## 2. Install Python3.8 for running Tensorflow 2.0
- Reference: https://python.tutorials24x7.com/blog/how-to-install-python-3-8-on-ubuntu-18-04-lts

```
sudo apt update
sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev
sudo wget https://www.python.org/ftp/python/3.8.2/Python-3.8.2.tar.xz
tar -xf Python-3.8.2.tar.xz

# Change directory
cd <path to download location>/Python-3.8.2

# Check dependencies
sudo ./configure --enable-optimizations

# Compile and build Python 
sudo make

# Install Binaries
sudo make altinstall

# Switch active Python
sudo update-alternatives --config python3 
```

## 3. Install the Microsoft ODBC driver for SQL Server (Microsoft ODBC 17)
- Reference: https://docs.microsoft.com/en-us/sql/connect/odbc/linux-mac/installing-the-microsoft-odbc-driver-for-sql-server?view=sql-server-ver15

```
sudo su
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

#Ubuntu 18.04
curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

exit
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install msodbcsql17
sudo ACCEPT_EULA=Y apt-get install mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
sudo apt-get install unixodbc-dev
```
## 4. Install OpenCV for image checking

```
apt-get update
apt-get install -y libsm6 libxext6 libxrender-dev
pip3.8 install opencv-python
```

## 5. Downgrade numpy to 1.16.4 for running Tensorflow2.0

```
pip3.8 uninstall numpy 
pip3.8 install numpy==1.16.4
```

## 6. Install required packages

```
pip3.8 install ipython
pip3.8 install -U matplotlib
pip3.8 install Flask
pip3.8 install flask-bootstrap
pip3.8 install pyodbc
pip3.8 install tensorflow-cpu
```

## 7. Install Docker (Optional)

```
# install Docker (optional)
apt-get update
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
    
# add the docker repo    
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
 
# install it
apt-get update
apt-get install docker-ce
```
