import sys, os, subprocess

def install_packages():
    print("\nInstalling required packeges...")
    subprocess.run(["sudo", "pacman", "-Sy", "--noconfirm" , "cpupower"], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)

if __name__ == '__main__':
    if os.geteuid() == 0:
        install_packages()
    else:
        print("\nChecking root privilage to run the script")
        subprocess.check_call(['sudo', sys.executable] + sys.argv)
