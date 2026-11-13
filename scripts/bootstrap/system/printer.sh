### Install Printers
#--------------------------------------------------------------

set -euo pipefail

PRINTER_NAME="HLL3230CDW"
PRINTER_MODEL="HL-L3230CDW"
DRIVER_RPM="hll3230cdwpdrv-1.0.2-0.i386.rpm"
DRIVER_URL="https://download.brother.com/welcome/dlf103944/${DRIVER_RPM}"

# Skip entirely if the printer is not visible on the network
if ! sudo lpinfo -v | grep -q "${PRINTER_MODEL}"; then
    echo "Printer ${PRINTER_MODEL} not found on network - skipping printer setup"
    exit 0
fi

# Install Brother driver (provides the PPD used below)
curl -fsSL "${DRIVER_URL}" -o "/tmp/${DRIVER_RPM}"
sudo dnf install -y "/tmp/${DRIVER_RPM}"
rm -f "/tmp/${DRIVER_RPM}"

# Add printer
sudo lpadmin -p "${PRINTER_NAME}" \
    -E \
    -v "ipp://Brother%20HL-L3230CDW%20series._ipp._tcp.local/" \
    -m "Brother/brother_hll3230cdw_printer_en.ppd" \
    -o media=a4 \
    -o sides=two-sided-long-edge

sudo lpoptions -d "${PRINTER_NAME}"
