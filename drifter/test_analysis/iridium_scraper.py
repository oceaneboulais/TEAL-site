import ftplib
import os
import time

# FTP server details
ftp_server = 'ftp.metocean.com'  # Replace with your FTP server address
username = 'alaferriere'      # Replace with your username
password = 'mWzgSGx$'      # Replace with your password
local_directory = '/Users/alaferri/Desktop/Seamounts2024/iridium_fixes/'  # Replace with your local directory path

# Interval to check for new files (in seconds)
check_interval = 60*5  # Adjust as needed

# Connect to the FTP server
ftp = None

def connect_ftp():
    global ftp
    try:
        ftp = ftplib.FTP(ftp_server)
        ftp.login(user=username, passwd=password)
        ftp.cwd('2024-06-22')  # Uncomment and specify the directory if needed
        # Set transfer mode to binary
        ftp.sendcmd('TYPE I')
    except ftplib.all_errors as e:
        print(f"Error connecting to FTP server: {e}")
        ftp = None

# ftp = ftplib.FTP(ftp_server)
# ftp.login(user=username, passwd=password)



# Change directory to where the file is located (if necessary)
# ftp.cwd('2024-06-20')  # Uncomment and specify the directory if needed

# Ensure local directory exists
os.makedirs(local_directory, exist_ok=True)

# Set to keep track of downloaded files
downloaded_files = set(os.listdir(local_directory))



# Function to download a file
def download_file(remote_file, local_file_path):
    #local_file_path = os.path.join(local_directory, os.path.basename(remote_file))
    try:
        with open(local_file_path, 'wb') as local_file:
            ftp.retrbinary('RETR ' + remote_file, local_file.write)

        # Check if the file size is zero
        if os.path.getsize(local_file_path) == 0:
            print(f"File {local_file_path} is empty, retrying download.")
            os.remove(local_file_path)

            # try download again
            with open(local_file_path, 'wb') as local_file:
                    ftp.retrbinary('RETR ' + remote_file, local_file.write)
            # if the file size is still zero, give up
            if os.path.getsize(local_file_path) == 0:
                print(f"Failed to download {local_file_path} correctly after retrying.")
            else:
                print(f"Downloaded: {local_file_path}")
        
        print(f'Downloaded: {local_file_path}')
        return os.path.basename(remote_file)
    except ftplib.all_errors as e:
        print(f"Error downloading file {remote_file}: {e}")
        return None

# Function to check for new files and download them
def check_for_new_files(downloaded_files):
    # ftp.retrlines('NLST', callback=process_file)
    # get the list of files
    try:
        # Get the list of files
        files = ftp.nlst()
        for file in files:
            process_file(file)
    except ftplib.all_errors as e:
        print(f"Error retrieving file list: {e}")
        # Reconnect if connection reset error occurs
        if not is_ftp_connected(ftp):
            print("Reconnecting to FTP server...")
            connect_ftp()

def process_file(remote_file):
    local_file_path = os.path.join(local_directory, os.path.basename(remote_file))  
    if os.path.isfile(local_file_path):
        zero_size = os.path.getsize(local_file_path) == 0
        if zero_size:
            os.remove(local_file_path)
    else:
        zero_size = False       
    if (remote_file not in downloaded_files) or zero_size:
        downloaded_files.add(remote_file)
        print("Downloading new file:" + remote_file) 
        download_file(remote_file, local_file_path)

def is_ftp_connected(ftp):
    if ftp is not None:
        try:
            ftp.voidcmd('NOOP')
            return True
        except ftplib.all_errors:
            return False
    return False

try:
    while True:
        if not is_ftp_connected(ftp):
            connect_ftp()
        ftp.voidcmd('NOOP')
        check_for_new_files(downloaded_files)
        time.sleep(check_interval)
except KeyboardInterrupt:
    print("Stopping the file checking loop.")
finally:
    # Close the FTP connection
    try:
        if ftp is not None and ftp.sock is not None:
            ftp.quit()
    except ftplib.all_errors as e:
        print(f"Error closing FTP connection: {e}")