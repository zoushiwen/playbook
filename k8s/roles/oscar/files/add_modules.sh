#!/bin/bash

ipvs_modules="ip_vs_rr ip_vs_sh ip_vs_wrr nf_conntrack_ipv4"

for kernel_module in ${ipvs_modules}; do
    /sbin/modinfo  ${kernel_module} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
    /sbin/modprobe ${kernel_module}
    fi
done


