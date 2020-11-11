#!/bin/bash
# debian: sudo apt install dpkg-dev devscripts dh-make dh-python dh-exec rpm
# fedora: sudo dnf install rpmdevtools rpm-sign python3-devel
# fedora: configure: error: C compiler cannot create executables? remove and reinstall glibc-devel gcc

cd "$(dirname "$0")"
version="1.0.0"


rm -rf builder/ ~/rpmbuild/
mkdir -p builder ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

# copy to a tmp directory
if [ true ]; then
	chmod 644 python-radexreader.spec
	spectool -g -R python-radexreader.spec
else
	temp=python-radexreader-${version}
	mkdir /tmp/${temp}
	cp -r ../* /tmp/${temp}/
	rm -rf /tmp/${temp}/*/builder/ /tmp/${temp}/radexreader/__pycache__/

	mv /tmp/${temp} builder/
	cp /usr/share/common-licenses/GPL-2 builder/${temp}/LICENSE

	cd builder/
	tar czf ${temp}.tar.gz ${temp}
	cd ..

	cp builder/${temp}.tar.gz ~/rpmbuild/SOURCES/python-radexreader-${version}.tar.gz
	chmod 644 python-radexreader.spec
fi

# create package (rpm sign https://access.redhat.com/articles/3359321)
rpmbuild --nodeps -ba python-radexreader.spec
rpm --addsign ~/rpmbuild/RPMS/*/*.rpm
rpm --addsign ~/rpmbuild/SRPMS/*.rpm
mv ~/rpmbuild/RPMS/*/*.rpm builder/
mv ~/rpmbuild/SRPMS/*.rpm builder/
echo "==========================="
rpm --checksig builder/*.rpm
echo "==========================="
rpmlint python-radexreader.spec builder/*.rpm
echo "==========================="
ls -dltrh $PWD/builder/*.rpm
echo "==========================="

# cleanup
rm -rf builder/*/ ~/rpmbuild/