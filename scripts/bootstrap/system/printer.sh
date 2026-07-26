### Install Printers
#--------------------------------------------------------------

set -euo pipefail

sudo lpadmin -p HLL3230CDW \
    -E \
    -v "ipp://Brother%20HL-L3230CDW%20series._ipp._tcp.local/" \
    -m "Brother/brother_hll3230cdw_printer_en.ppd" \
    -o media=a4 \
    -o sides=two-sided-long-edge

sudo lpoptions -d HLL3230CDW
