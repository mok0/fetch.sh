#!/bin/bash

# // CPU // try cpu model from lscpu if not found /proc/cpuinfo
vendor=$(head /proc/cpuinfo | grep -m1 "vendor_id" | sed 's/vendor_id//' | tr -d '\t :')
intel_strip="s/Processor//;s/(TM)//;s/(R)//;s/@//;s/CPU//;s/^ *//;s/.......$//"
echo -ne "${RED}cpu${NC} ~ "
if [[ $(command -v lscpu) ]] ; then
        lscpu | grep 'Model name' | sed 's/Model name://;s/Processor//;s/(TM)//;s/(R)//;s/@//;s/CPU//;s/^ *//' | tr -d '\n'
elif [[ $($vendor = "GenuineIntel") ]] ; then
	lscpu | grep 'Model name' | sed "$intel_strip"
elif [[ $($vendor = "GenuineIntel") ]] ; then
	awk -F: '/model name/{print $2 ; exit}' /proc/cpuinfo | sed "$intel_strip"
else
        awk -F: '/model name/{print $2 ; exit}' /proc/cpuinfo | sed 's/Processor//;s/CPU//;s/^ *//' | tr -d '\n'
fi


# get cpu frequency if /sys/devices/system/cpu exist
if [[ -e /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq ]] ; then
        max_cpu=$(head /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq | sed 's/......$/.&/;s/.....$//' | tr -d '\n')
        cur_cpu=$(head /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq | sed 's/......$/.&/;s/....$//' | tr -d '\n')
        echo -ne "${CYAN}$max_cpu${NC}"
        echo -ne "@${YELLOW}$cur_cpu${NC}" ; echo GHz
else
        echo -ne "\n"
fi


# // GPU // with lscpi
if [[ $(command -v lspci) ]] ; then
        echo -ne "${PURPLE}gpu${NC} ~ "
        lspci | grep -im1 --color 'vga\|3d\|2d' | sed 's/VGA compatible controller//;s/Advanced Micro Devices, Inc//;s/NVIDIA Corporation//;s/Corporation//;s/Controller//;s/controller//;s/storage//;s/filesystem//;s/0000//;s/Family//;s/Processor//;s/Mixture//;s/Model//;s/Generation/Gen/g' | tr -d '.:[]' | sed 's/^.....//;s/^ *//'
else
        echo -ne "\n"
fi
