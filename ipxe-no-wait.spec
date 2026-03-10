Name:           ipxe-no-wait
Version:        2.0.0
Release:        1%{?dist}
Summary:        iPXE boot images optimized for fast PXE boot on IPv4 networks

License:        GPL-2.0-or-later
URL:            https://github.com/ed-vazquez/ipxe-no-wait
Source0:        %{url}/releases/download/v%{version}/ipxeboot.tar.gz

BuildArch:      noarch

%description
Pre-built iPXE network boot firmware with reduced boot times for IPv4-only
PXE environments. Disables IPv6 and ProxyDHCP wait times, saving roughly
10 seconds compared to stock iPXE.

Includes binaries for x86_64 (BIOS + UEFI), ARM32 (UEFI), and ARM64 (UEFI).

%prep
%setup -q -n ipxeboot

%build
# Pre-built binaries, nothing to compile

%install
mkdir -p %{buildroot}%{_datadir}/%{name}
cp -a . %{buildroot}%{_datadir}/%{name}/

%files
%{_datadir}/%{name}/

%changelog
* Mon Mar 10 2026 Eduardo Vazquez <evazquez@vazqueztech.com> - 2.0.0-1
- Upgrade to iPXE v2.0.0
- Add ARM32 and ARM64 EFI binaries
- Use iPXE official builder images for reproducible builds

* Thu Feb 19 2026 Eduardo Vazquez <evazquez@vazqueztech.com> - 1.21.1-1
- Initial package
