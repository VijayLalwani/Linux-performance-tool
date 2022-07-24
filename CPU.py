import sys, os, subprocess

def set_frequency(frequency):
    subprocess.run(["sudo", "cpupower", "frequency-set", "-f" + frequency], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT) #CalledProcessError exception caught

def set_minimum_frequency(frequency):
    subprocess.run(["sudo", "cpupower", "frequency-set", "-d" + frequency], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)

def set_maximum_frequency(frequency):
    subprocess.run(["sudo", "cpupower", "frequency-set", "-u" + frequency], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)

def set_governer(governer):
    subprocess.run(["sudo", "cpupower", "frequency-set", "-g" + governer], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)



