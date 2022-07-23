import sys, os, subprocess

def install_packages():
    print("\n \n Installing required packeges...\n \n ")
    subprocess.run(["sudo", "pacman", "-Sy", "--noconfirm" , "cpupower"], check=True)

if __name__ == '__main__':
    if os.geteuid() == 0:
        install_packages()
    else:
        print("\n \n Need root privilage to run the script\n \n ")
        subprocess.check_call(['sudo', sys.executable] + sys.argv)
